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
  internal let refreshInterval: TimeInterval

  private var repoTasks: [UUID: Task<Void, Never>] = [:]

  public init(
    model: Model,
    token: String,
    apiServer: String,
    refreshInterval: TimeInterval = 30.0
  ) {
    self.token = token
    self.apiServer = apiServer
    self.refreshInterval = refreshInterval
    super.init(model: model)
  }

  override func startRefresh() {
    cancelRefresh()

    let repos = Array(model.items.values)
    for (index, repo) in repos.enumerated() {
      repoTasks[repo.id] = Task { [weak self] in
        guard let self else { return }
        let initialDelay = UInt64(index) * 1_000_000_000
        if initialDelay > 0 {
          try? await Task.sleep(nanoseconds: initialDelay)
        }

        await self.runPollingLoop(for: repo)
      }
    }
  }

  override func cancelRefresh() {
    for task in repoTasks.values {
      task.cancel()
    }
    repoTasks.removeAll()
  }

  private func runPollingLoop(for repo: Repo) async {
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

  func update(repo: Repo, with run: WorkflowRun) {
    refreshChannel.log("\(repo.name) status: \(run.status), conclusion: \(run.conclusion ?? "")")
    let state: Repo.State

    switch run.status {
      case "queued":
        state = .queued
      case "pending", "requested", "waiting":
        state = .queued
      case "in_progress":
        state = .running
      case "completed":
        switch run.conclusion {
          case "success":
            state = .passing
          case "neutral", "skipped", "cancelled":
            state = .passing
          case "failure", "timed_out", "action_required", "startup_failure", "stale":
            state = .failing
          default:
            refreshChannel.log("Unmapped completed conclusion for \(repo.name): \(run.conclusion ?? "<nil>")")
            state = .unknown
        }
      default:
        refreshChannel.log("Unmapped workflow status for \(repo.name): \(run.status)")
        state = .unknown
    }

    DispatchQueue.main.async {
      self.model.update(repoWithID: repo.id, state: state)
    }
  }
}

private enum RequestResult<Payload> {
  case payload(Payload)
  case apiMessage(Message)
  case timedOut
}

/// Per-repository task runner for events and workflow polling.
private actor RepoPoller {
  private let repo: Repo
  private let session: JSONSession.Session
  private unowned let refreshController: OctoidRefreshController
  private let refreshInterval: TimeInterval

  private var lastEvent: Date
  private var shouldPollEvents = true
  private var shouldPollWorkflow = true

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

  deinit {
    session.cancel()
  }

  func run() async {
    while !Task.isCancelled {
      if shouldPollEvents {
        await pollEvents()
      }

      if shouldPollWorkflow {
        await pollWorkflow()
      }

      if Task.isCancelled { break }
      try? await Task.sleep(nanoseconds: UInt64(refreshInterval * 1_000_000_000))
    }

    session.cancel()
  }

  private func pollEvents() async {
    refreshChannel.log("polling events for \(fullName)")
    let resource = EventsResource(name: repo.name, owner: repo.owner)
    switch await request(target: resource, as: Events.self) {
      case .payload(let events):
        var wasPushed = false
        var latestEvent = lastEvent

        for event in events where event.created_at > lastEvent {
          if event.type == "PushEvent" {
            refreshChannel.log("Found new event: \(event.type) \(event.id) \(event.created_at)")
            wasPushed = true
          }
          latestEvent = max(latestEvent, event.created_at)
        }

        lastEvent = latestEvent
        Self.saveLastEvent(latestEvent, forKey: lastEventKey)

        if wasPushed && shouldPollWorkflow {
          await pollWorkflow()
        }

      case .apiMessage(let message):
        if message.message == "Not Found" {
          // Some repositories don't expose events to this token.
          refreshChannel.log("Events endpoint unavailable for \(fullName); stopping events polling.")
          shouldPollEvents = false
        } else {
          refreshController.update(repo: repo, message: message)
        }

      case .timedOut:
        refreshChannel.log("Timed out polling events for \(fullName)")
    }
  }

  private func pollWorkflow() async {
    let workflow = repo.workflow.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !workflow.isEmpty else {
      refreshChannel.log("Skipping workflow polling for \(fullName) because workflow name is empty.")
      return
    }

    refreshChannel.log("polling workflow for \(fullName): \(workflow)")
    let resource = WorkflowResource(name: repo.name, owner: repo.owner, workflow: workflow)
    switch await request(target: resource, as: WorkflowRuns.self) {
      case .payload(let runs):
        guard !runs.isEmpty else {
          shouldPollWorkflow = false
          return
        }

        refreshController.update(repo: repo, with: runs.latestRun)

      case .apiMessage(let message):
        refreshController.update(repo: repo, message: message)
        if message.message == "Not Found" {
          // No matching workflow for this repo; stop querying it repeatedly.
          shouldPollWorkflow = false
        }

      case .timedOut:
        refreshChannel.log("Timed out polling workflow for \(fullName)")
    }
  }

  private func request<Payload: Decodable>(
    target: ResourceResolver,
    as _: Payload.Type,
    timeout: TimeInterval = 30
  ) async -> RequestResult<Payload> {
    let context = ResponseContext<Payload>()
    let group = AnyProcessorGroup<ResponseContext<Payload>>(
      name: "\(Payload.self)",
      processors: [
        PayloadCaptureProcessor<Payload>().eraseToAnyProcessor(),
        MessageProcessor<ResponseContext<Payload>>().eraseToAnyProcessor(),
      ]
    )

    session.poll(
      target: target,
      context: context,
      processors: group,
      for: .now()
    )

    return await context.awaitResult(timeout: timeout)
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

/// Polling context that captures either a typed payload or GitHub API message.
private actor ResponseContext<Payload>: MessageReceiver {
  private var payload: Payload?
  private var message: Message?

  func capture(_ payload: Payload) {
    self.payload = payload
  }

  func received(
    _ message: Message,
    response _: HTTPURLResponse,
    for _: Request<ResponseContext<Payload>>
  ) async -> RepeatStatus {
    self.message = message
    return .cancel
  }

  func awaitResult(timeout: TimeInterval) async -> RequestResult<Payload> {
    let expiry = Date().addingTimeInterval(timeout)
    while Date() < expiry {
      if let payload {
        return .payload(payload)
      }

      if let message {
        return .apiMessage(message)
      }

      try? await Task.sleep(nanoseconds: 100_000_000)
    }

    return .timedOut
  }
}

/// Processor that stores a decoded payload in the response context.
private struct PayloadCaptureProcessor<Payload: Decodable>: Processor {
  typealias Context = ResponseContext<Payload>

  let name = "payload capture"
  let codes = [200]

  func process(
    _ payload: Payload,
    response _: HTTPURLResponse,
    for _: Request<ResponseContext<Payload>>,
    in context: ResponseContext<Payload>
  ) async throws -> RepeatStatus {
    await context.capture(payload)
    return .cancel
  }
}
