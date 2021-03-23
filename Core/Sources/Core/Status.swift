// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class Status: ObservableObject {
    @Published public var sortedRepos: [Repo] = []
    @Published public var passing: Int = 0
    @Published public var failing: Int = 0
    @Published public var running: Int = 0
    @Published public var queued: Int = 0
    @Published public var unreachable: Int = 0
    
    public func update(with model: Model, viewState: ViewState) {
        print("updated")
        sortedRepos = model.repos(sortedBy: viewState.sortMode)
        let set = NSCountedSet()
        sortedRepos.forEach({ set.add($0.state) })

        passing = set.count(for: Repo.State.passing)
        failing = set.count(for: Repo.State.failing)
        running = set.count(for: Repo.State.running)
        queued = set.count(for: Repo.State.queued)
        unreachable = set.count(for: Repo.State.unknown)
    }
}
