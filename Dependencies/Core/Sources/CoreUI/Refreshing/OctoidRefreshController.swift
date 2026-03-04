// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 29/07/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Foundation
import JSONSession
import Octoid

/// Refresh controller that polls GitHub APIs through Octoid resources.
///
/// The implementation uses one task per repository to keep polling work
/// isolated and cancellation-friendly while preserving the existing behavior:
/// periodic workflow checks, optional events checks, and a persisted event
/// cursor used to trigger extra workflow refreshes after pushes.
public class OctoidRefreshController: RefreshController {
  internal let token: String
  internal let apiServer: String
  internal let fallbackRefreshInterval: TimeInterval

  private var repoTasks: [String: Task<Void, Never>] = [:]

  public init(
    model: Model,
    token: String,
    apiServer: String,
    refreshInterval: TimeInterval = RefreshRate.minute.rate
  ) {
    self.token = token
    self.apiServer = apiServer
    self.fallbackRefreshInterval = refreshInterval
    super.init(model: model)
  }

  override func startRefresh() {
    cancelRefresh()
    let interval = activeRefreshInterval

    let repos = Array(model.items.values)
    refreshChannel.log("Starting refresh for \(repos.count) repos at \(interval)s interval.")
    for (index, repo) in repos.enumerated() {
      repoTasks[repo.id] = Task { [weak self] in
        guard let self else { return }
        let initialDelay = UInt64(index) * 1_000_000_000
        if initialDelay > 0 {
          let delaySeconds = Double(initialDelay) / 1_000_000_000
          refreshChannel.log("Scheduling first poll for \(repo.owner)/\(repo.name) in \(delaySeconds)s.")
        } else {
          refreshChannel.log("Scheduling first poll for \(repo.owner)/\(repo.name) immediately.")
        }
        if initialDelay > 0 {
          try? await Task.sleep(nanoseconds: initialDelay)
        }

        await self.runPollingLoop(for: repo, refreshInterval: interval)
      }
    }
  }

  override func cancelRefresh() {
    for task in repoTasks.values {
      task.cancel()
    }
    repoTasks.removeAll()
  }

  override func refreshRateDidChange(to _: Double) {
    cancelRefresh()
    startRefresh()
  }

  private var activeRefreshInterval: TimeInterval {
    if case .running(let rate) = state {
      return rate
    }
    return fallbackRefreshInterval
  }

  private func runPollingLoop(for repo: Repo, refreshInterval: TimeInterval) async {
    let baseURL =
      (try? GithubDeviceAuthenticator.normalizedAPIBaseURL(for: apiServer))
      ?? URL(string: "https://api.github.com")!
    let session = JSONSession.Session(base: baseURL, token: token)
    let poller = RepoPoller(
      repo: repo,
      session: session,
      refreshController: self,
      refreshInterval: refreshInterval
    )
    await poller.run()
  }

  func update(repo: Repo, message: Message) {
    refreshChannel.log("Error for \(repo.name) was: \(message.message)")
    DispatchQueue.main.async {
      self.model.update(repoWithID: repo.id, state: .unknown)
    }
  }

  func state(for run: WorkflowRun, in repo: Repo) -> Repo.State {
    refreshChannel.log("\(repo.name) status: \(run.status), conclusion: \(run.conclusion ?? "")")

    switch run.status {
      case "queued":
        return .queued
      case "pending", "requested", "waiting":
        return .queued
      case "in_progress":
        return .running
      case "completed":
        switch run.conclusion {
          case "success":
            return .passing
          case "neutral", "skipped", "cancelled":
            return .passing
          case "failure", "timed_out", "action_required", "startup_failure", "stale":
            return .failing
          default:
            refreshChannel.log("Unmapped completed conclusion for \(repo.name): \(run.conclusion ?? "<nil>")")
            return .unknown
        }
      default:
        refreshChannel.log("Unmapped workflow status for \(repo.name): \(run.status)")
        return .unknown
    }
  }

  func aggregateState(for states: [Repo.State]) -> Repo.State {
    guard !states.isEmpty else { return .unknown }

    let failingCount = states.filter { $0 == .failing }.count
    if failingCount == states.count {
      return .failing
    }
    if failingCount > 0 {
      return .partiallyFailing
    }
    if states.contains(.running) {
      return .running
    }
    if states.contains(.queued) {
      return .queued
    }
    if states.allSatisfy({ $0 == .passing }) {
      return .passing
    }
    return .unknown
  }

  func update(repo: Repo, with state: Repo.State) {
    DispatchQueue.main.async {
      self.model.update(repoWithID: repo.id, state: state)
    }
  }

  @discardableResult
  func merge(repo: Repo, discovered workflows: [Repo.WorkflowSelection]) async -> Repo {
    await MainActor.run {
      guard var current = self.model.repo(withIdentifier: repo.id) else { return repo }
      if current.mergeDiscoveredWorkflows(workflows) {
        self.model.update(repo: current)
      }
      return current
    }
  }
}

/// Per-repository task runner for events and workflow polling.
private actor RepoPoller {
  private enum WorkflowKey: Hashable {
    case id(Int)
    case name(String)
  }

  private let repo: Repo
  private let session: JSONSession.Session
  private unowned let refreshController: OctoidRefreshController
  private let refreshInterval: TimeInterval

  private var lastEvent: Date
  private var shouldPollEvents = true
  private var shouldPollWorkflows = true
  private var shouldRestartStream = false
  private var workflowStates: [WorkflowKey: Repo.State] = [:]

  private var fullName: String { "\(repo.owner)/\(repo.name)" }
  private var lastEventKey: String { "\(fullName)-lastEvent" }

  init(
    repo: Repo,
    session: JSONSession.Session,
    refreshController: OctoidRefreshController,
    refreshInterval: TimeInterval
  ) {
    self.repo = repo
    self.session = session
    self.refreshController = refreshController
    self.refreshInterval = refreshInterval
    self.lastEvent = Self.loadLastEvent(forKey: "\(repo.owner)/\(repo.name)-lastEvent")
  }

  func run() async {
    while !Task.isCancelled {
      shouldRestartStream = false
      let stream = session.repositoryUpdates(
        for: RepositoryReference(owner: repo.owner, name: repo.name),
        configuration: RepositoryPollConfiguration(
          interval: .seconds(refreshInterval),
          pollEvents: shouldPollEvents,
          pollWorkflows: shouldPollWorkflows
        )
      )

      for await update in stream {
        if Task.isCancelled || shouldRestartStream {
          break
        }
        await handle(update)
      }

      if Task.isCancelled {
        break
      }

      if !shouldRestartStream {
        try? await Task.sleep(nanoseconds: 500_000_000)
      }
    }
  }

  private func handle(_ update: RepositoryUpdate) async {
    switch update {
    case .events(let events):
      await handleEvents(events)

    case .workflows(let workflows):
      await handleWorkflows(workflows)

    case .workflowRuns(let target, let runs):
      await handleWorkflowRuns(target: target, runs: runs)

    case .message(let source, let message):
      await handleMessage(source: source, message: message)

    case .transportError(let source, let description):
      refreshChannel.log("Transport error for \(fullName) (\(source)): \(description)")
    }
  }

  private func handleEvents(_ events: Events) async {
    var latestEvent = lastEvent
    for event in events where event.created_at > lastEvent {
      latestEvent = max(latestEvent, event.created_at)
    }

    guard latestEvent != lastEvent else {
      return
    }

    lastEvent = latestEvent
    Self.saveLastEvent(latestEvent, forKey: lastEventKey)
  }

  private func handleWorkflows(_ response: Workflows) async {
    let discovered = response.workflows.map {
      Repo.WorkflowSelection(workflowID: $0.id, name: $0.name, path: $0.path)
    }
    let updated = await refreshController.merge(repo: repo, discovered: discovered)
    if updated.enabledWorkflows.isEmpty {
      refreshController.update(repo: updated, with: .unknown)
    }
  }

  private func handleWorkflowRuns(target: RepositoryWorkflowTarget, runs: WorkflowRuns) async {
    guard let latestRepo = await MainActor.run(resultType: Repo?.self, body: { refreshController.model.repo(withIdentifier: repo.id) }) else {
      return
    }

    let enabled = latestRepo.enabledWorkflows
    guard !enabled.isEmpty else {
      refreshController.update(repo: latestRepo, with: .unknown)
      return
    }

    let idKey = WorkflowKey.id(target.workflowID)
    let nameKey = WorkflowKey.name(target.normalizedName)
    let isEnabled = enabled.contains { selection in
      if let workflowID = selection.workflowID {
        return workflowID == target.workflowID
      }
      return selection.normalizedWorkflowName == target.normalizedName
    }
    guard isEnabled else {
      return
    }

    if runs.isEmpty {
      workflowStates.removeValue(forKey: idKey)
      workflowStates.removeValue(forKey: nameKey)
    } else {
      let state = refreshController.state(for: runs.latestRun, in: repo)
      workflowStates[idKey] = state
      workflowStates[nameKey] = state
    }

    let relevantStates: [Repo.State] = enabled.compactMap { selection in
      if let workflowID = selection.workflowID {
        return workflowStates[.id(workflowID)]
      }
      return workflowStates[.name(selection.normalizedWorkflowName)]
    }

    if relevantStates.isEmpty {
      refreshController.update(repo: latestRepo, with: .dormant)
      return
    }

    let aggregate = refreshController.aggregateState(for: relevantStates)
    refreshController.update(repo: latestRepo, with: aggregate)
  }

  private func handleMessage(source: RepositoryUpdateSource, message: Message) async {
    switch source {
    case .events:
      if message.message == "Not Found" {
        refreshChannel.log("Events endpoint unavailable for \(fullName); stopping events polling.")
        shouldPollEvents = false
        shouldRestartStream = true
      } else {
        refreshController.update(repo: repo, message: message)
      }

    case .workflows:
      refreshController.update(repo: repo, message: message)
      if message.message == "Not Found" {
        shouldPollWorkflows = false
        workflowStates.removeAll()
        shouldRestartStream = true
      }

    case .workflowRuns(let target):
      refreshChannel.log("Workflow runs unavailable for \(fullName) (\(target.name)): \(message.message)")
    }
  }

  private static func loadLastEvent(forKey key: String) -> Date {
    let seconds = UserDefaults.standard.double(forKey: key)
    guard seconds != 0 else {
      return Date(timeIntervalSinceReferenceDate: 0)
    }

    return Date(timeIntervalSinceReferenceDate: seconds)
  }

  private static func saveLastEvent(_ date: Date, forKey key: String) {
    UserDefaults.standard.set(date.timeIntervalSinceReferenceDate, forKey: key)
  }
}
