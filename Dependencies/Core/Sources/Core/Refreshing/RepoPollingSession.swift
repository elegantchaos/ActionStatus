// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/04/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Foundation
import JSONSession
import Logger
import Octoid

public class RepoPollingSession: JSONSession.Session {
  let repo: Repo
  let workflowProcessor = WorkflowGroupProcessor()
  let eventsProcessor = EventsGroupProcessor()
  let refreshController: OctoidRefreshController
  var lastEvent: Date

  public var fullName: String { return "\(repo.owner)/\(repo.name)" }
  var tagKey: String { return "\(fullName)-tag" }
  var lastEventKey: String { return "\(fullName)-lastEvent" }

  public init(controller: OctoidRefreshController, repo: Repo, token: String, apiServer: String) {
    self.refreshController = controller
    self.repo = repo
    self.lastEvent = Date(timeIntervalSinceReferenceDate: 0)
    let base = (try? GithubDeviceAuthenticator.normalizedAPIBaseURL(for: apiServer)) ?? URL(string: "https://api.github.com")!
    super.init(base: base, token: token)
    load()
  }

  func load() {
    let seconds = UserDefaults.standard.double(forKey: lastEventKey)
    if seconds != 0 {
      lastEvent = Date(timeIntervalSinceReferenceDate: seconds)
    }
  }

  func save() {
    let defaults = UserDefaults.standard
    defaults.set(lastEvent.timeIntervalSinceReferenceDate, forKey: lastEventKey)
  }

  public func scheduleEvents(for deadline: DispatchTime = DispatchTime.now()) {
    refreshChannel.log("scheduling request for \(fullName)")
    let resource = EventsResource(name: repo.name, owner: repo.owner)
    poll(target: resource, processors: eventsProcessor, for: deadline, repeatingEvery: 30.0)
  }

  public func scheduleWorkflow(for deadline: DispatchTime = DispatchTime.now()) {
    refreshChannel.log("scheduling workflow request for \(fullName)")
    let resource = WorkflowResource(name: repo.name, owner: repo.owner, workflow: repo.workflow)
    poll(target: resource, processors: workflowProcessor, for: deadline, repeatingEvery: 30.0)
  }
}

extension RepoPollingSession: MessageReceiver {
  public func received(_ message: Message, response: HTTPURLResponse, for request: Request) -> RepeatStatus {
    if (request.resource is EventsResource) && (message.message == "Not Found") {
      // Some repositories don't expose events to this token; keep polling workflow status.
      refreshChannel.log("Events endpoint unavailable for \(fullName); cancelling events polling.")
      return .cancel
    }

    // We got an API error back from a request.
    refreshController.update(repo: repo, message: message)
    if (request.resource is WorkflowResource) && (message.message == "Not Found") {
      // there's no workflow, so don't keep polling for it
      return .cancel
    }
    return .inherited
  }
}
