// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 29/07/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Octoid

public class OctoidRefreshController: RefreshController {
  internal var sessions: [RepoPollingSession]
  internal let token: String
  internal let apiServer: String

  public init(model: Model, token: String, apiServer: String) {
    self.sessions = []
    self.token = token
    self.apiServer = apiServer
    super.init(model: model)
  }

  override func startRefresh() {
    var sessions: [RepoPollingSession] = []
    let filter: String? = nil
    var deadline = DispatchTime.now()
    for repo in model.items.values {
      if filter == nil || filter == repo.name {
        let session = RepoPollingSession(controller: self, repo: repo, token: token, apiServer: apiServer)
        session.scheduleEvents(for: deadline)
        session.scheduleWorkflow(for: deadline)
        sessions.append(session)
        deadline = deadline.advanced(by: .seconds(1))
      }
    }
    self.sessions = sessions
  }

  override func cancelRefresh() {
    for session in sessions {
      session.cancel()
    }
    self.sessions.removeAll()
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
      case "in_progress":
        state = .running
      case "completed":
        switch run.conclusion {
          case "success":
            state = .passing
          case "failure":
            state = .failing
          default:
            state = .unknown
        }
      default:
        state = .unknown
    }

    DispatchQueue.main.async {
      self.model.update(repoWithID: repo.id, state: state)
    }
  }
}
