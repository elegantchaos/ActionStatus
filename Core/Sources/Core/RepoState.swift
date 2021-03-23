// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Logger

let repoStateChannel = Channel("RepoState")

public class RepoState: ObservableObject {
    @Published public var sortedRepos: [Repo] = []
    @Published public var passing: Int = 0
    @Published public var failing: Int = 0
    @Published public var running: Int = 0
    @Published public var queued: Int = 0
    @Published public var unreachable: Int = 0

    public func update(with model: Model, viewState: ViewState) {
        repoStateChannel.log("updated")
        sortedRepos = model.repos(sortedBy: viewState.sortMode)

        let set = NSCountedSet()
        sortedRepos.forEach({ set.add($0.state) })
        passing = set.count(for: Repo.State.passing)
        failing = set.count(for: Repo.State.failing)
        running = set.count(for: Repo.State.running)
        queued = set.count(for: Repo.State.queued)
        unreachable = set.count(for: Repo.State.unknown)
    }
    
    public func repo(withIndex index: Int) -> Repo {
        return sortedRepos[index]
    }
    
    public func name(forRepoWithIndex index: Int) -> String {
        return sortedRepos[index].name
    }
    
    public func state(forRepoWithIndex index: Int) -> Repo.State {
        return sortedRepos[index].state
    }
    
    public func repoIDs(atOffets offsets: IndexSet) -> [UUID] {
        let ids = offsets.map({ self.sortedRepos[$0] })
        return ids.map({ $0.id })
    }

    public var combinedState: [Repo.State] {
        var state: [Repo.State] = []
        if running > 0 {
            state.append(.running)
        }
        
        if queued > 0 {
            state.append(.queued)
        }
        
        if failing > 0 {
            state.append(.failing)
        }
        
        if state.count == 0 {
            state = (passing > 0) ? [.passing] : [.unknown]
        }
        return state
    }
}
