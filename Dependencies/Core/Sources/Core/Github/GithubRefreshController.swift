// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 29/07/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import JSONSession
import Octoid

/// Refresh controller that polls GitHub APIs through Octoid resources.
@MainActor
public final class GithubRefreshController: RefreshController {
  internal let token: String
  internal let apiServer: String
  internal let fallbackRefreshInterval: TimeInterval
  internal let lastEventStore: any LastEventStore

  private var repoTasks: [String: Task<Void, Never>] = [:]

  public init(
    model: ModelService,
    token: String,
    apiServer: String,
    refreshInterval: TimeInterval? = nil,
    lastEventStore: any LastEventStore
  ) {
    self.token = token
    self.apiServer = apiServer
    self.fallbackRefreshInterval = refreshInterval ?? RefreshRate.minute.rate
    self.lastEventStore = lastEventStore
    super.init(model: model)
  }

  override func startRefresh() {
    cancelRefresh()
    let interval = activeRefreshInterval

    let repos = Array(model.items.values)
    refreshChannel.log("Starting refresh for \(repos.count) repos at \(interval)s interval.")
    for (index, repo) in repos.enumerated() {
      let token = token
      let apiServer = apiServer
      repoTasks[repo.id] = Task {
        let initialDelay = UInt64(index) * 1_000_000_000
        if initialDelay > 0 {
          let delaySeconds = Double(initialDelay) / 1_000_000_000
          refreshChannel.log("Scheduling first poll for \(repo.owner)/\(repo.name) in \(delaySeconds)s.")
        } else {
          refreshChannel.log("Scheduling first poll for \(repo.owner)/\(repo.name) immediately.")
        }
        if initialDelay > 0 {
          do {
            try await Task.sleep(nanoseconds: initialDelay)
          } catch is CancellationError {
            return
          } catch {
            return
          }
        }
        guard !Task.isCancelled else { return }

        let baseURL =
          (try? GithubDeviceAuthenticator.normalizedAPIBaseURL(for: apiServer))
          ?? URL(string: "https://api.github.com")!
        let session = JSONSession.Session(base: baseURL, token: token)
        let poller = RepoPoller(
          repo: repo,
          session: session,
          refreshController: self,
          refreshInterval: interval,
          lastEventStore: lastEventStore
        )
        await poller.run()
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

  func update(repo: Repo, message: Message) {
    refreshChannel.log("Error for \(repo.name) was: \(message.message)")
    model.updateState(.unknown, forRepoWithID: repo.id)
  }

  func state(for run: WorkflowRun, in repo: Repo) -> Repo.State {
    refreshChannel.log("\(repo.name) status: \(run.status), conclusion: \(run.conclusion ?? "")")

    switch run.status {
      case "queued", "pending", "requested", "waiting":
        return .queued
      case "in_progress":
        return .running
      case "completed":
        switch run.conclusion {
          case "success", "neutral", "skipped", "cancelled":
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
    model.updateState(state, forRepoWithID: repo.id)
  }

  @discardableResult
  func merge(repo: Repo, discovered workflows: [Repo.WorkflowSelection]) -> Repo {
    guard var current = model.repo(withIdentifier: repo.id) else { return repo }
    if current.mergeDiscoveredWorkflows(workflows) {
      model.update(repo: current)
    }
    return current
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
  private unowned let refreshController: GithubRefreshController
  private let refreshInterval: TimeInterval
  private let lastEventStore: any LastEventStore

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
    refreshController: GithubRefreshController,
    refreshInterval: TimeInterval,
    lastEventStore: any LastEventStore
  ) {
    self.repo = repo
    self.session = session
    self.refreshController = refreshController
    self.refreshInterval = refreshInterval
    self.lastEventStore = lastEventStore
    self.lastEvent = Date(timeIntervalSinceReferenceDate: 0)
  }

  func run() async {
    lastEvent = await lastEventStore.lastEvent(forKey: lastEventKey)
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
        let fullName = self.fullName
        await MainActor.run {
          refreshChannel.log("Transport error for \(fullName) (\(source)): \(description)")
        }
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
    await lastEventStore.setLastEvent(latestEvent, forKey: lastEventKey)
  }

  private func handleWorkflows(_ response: Workflows) async {
    let discovered = response.workflows.map {
      Repo.WorkflowSelection(workflowID: $0.id, name: $0.name, path: $0.path)
    }
    let updated = await refreshController.merge(repo: repo, discovered: discovered)
    if updated.enabledWorkflows.isEmpty {
      await refreshController.update(repo: updated, with: .unknown)
    }
  }

  private func handleWorkflowRuns(target: RepositoryWorkflowTarget, runs: WorkflowRuns) async {
    guard let latestRepo = await MainActor.run(body: { refreshController.model.repo(withIdentifier: repo.id) }) else {
      return
    }

    let enabled = latestRepo.enabledWorkflows
    guard !enabled.isEmpty else {
      await refreshController.update(repo: latestRepo, with: .unknown)
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
      let state = await refreshController.state(for: runs.latestRun, in: repo)
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
      await refreshController.update(repo: latestRepo, with: .dormant)
      return
    }

    let aggregate = await refreshController.aggregateState(for: relevantStates)
    await refreshController.update(repo: latestRepo, with: aggregate)
  }

  private func handleMessage(source: RepositoryUpdateSource, message: Message) async {
    switch source {
      case .events:
        if message.message == "Not Found" {
          let fullName = self.fullName
          await MainActor.run {
            refreshChannel.log("Events endpoint unavailable for \(fullName); stopping events polling.")
          }
          shouldPollEvents = false
          shouldRestartStream = true
        } else {
          await refreshController.update(repo: repo, message: message)
        }

      case .workflows:
        await refreshController.update(repo: repo, message: message)
        if message.message == "Not Found" {
          shouldPollWorkflows = false
          workflowStates.removeAll()
          shouldRestartStream = true
        }

      case .workflowRuns(let target):
        let fullName = self.fullName
        await MainActor.run {
          refreshChannel.log("Workflow runs unavailable for \(fullName) (\(target.name)): \(message.message)")
        }
    }
  }
}
