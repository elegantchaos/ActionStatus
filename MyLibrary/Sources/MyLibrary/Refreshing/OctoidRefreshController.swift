// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 29/07/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Octoid

public class OctoidRefreshController: RefreshController {
    internal var sessions: [RepoPollingSession]
    internal let token: String
    
    public init(model: Model, viewState: ViewState, token: String) {
        self.sessions = []
        self.token = token
        super.init(model: model, viewState: viewState)
    }

    override func startRefresh() {
        var sessions: [RepoPollingSession] = []
        let filter: String? = nil
        var deadline = DispatchTime.now()
        for repo in model.items.values {
            if filter == nil || filter == repo.name {
                let session = RepoPollingSession(controller: self, repo: repo, token: token)
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
        var updated = repo
        updated.state = .unknown
        DispatchQueue.main.async {
            self.model.update(repo: updated)
        }

    }
    
    func update(repo: Repo, with run: WorkflowRun) {
        refreshChannel.log("\(repo.name) status: \(run.status), conclusion: \(run.conclusion ?? "")")
        var updated = repo
        switch run.status {
            case "queued":
                updated.state = .queued
            case "in_progress":
                updated.state = .running
            case "completed":
                switch run.conclusion {
                    case "success":
                        updated.state = .passing
                    case "failure":
                        updated.state = .failing
                    default:
                        updated.state = .unknown
                }
            default:
                updated.state = .unknown
        }

        DispatchQueue.main.async {
            self.model.update(repo: updated)
        }
    }
}
