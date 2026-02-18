// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/07/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import JSONSession
import Octoid

struct WorkflowRunsProcessor: Processor {
    typealias SessionType = RepoPollingSession
    typealias Payload = WorkflowRuns
    
    let codes = [200]
    let name = "workflows"
    
    var processors: [ProcessorBase] {
        return [self, MessageProcessor<RepoPollingSession>()]
    }
    
    func process(_ runs: WorkflowRuns, response: HTTPURLResponse, for request: Request, in session: RepoPollingSession) -> RepeatStatus {
        
        if runs.isEmpty {
            return .cancel
        }
        
        let latest = runs.latestRun
        session.refreshController.update(repo: session.repo, with: latest)
        if latest.status == "completed" {
            return .cancel
        } else {
            return .inherited
        }
    }
}

struct WorkflowGroupProcessor: ProcessorGroup {
    let name = "workflows"
    var processors: [ProcessorBase] = [
        WorkflowRunsProcessor(),
        UnchangedProcessor(),
        MessageProcessor<RepoPollingSession>()
    ]
}
