// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Foundation
import Logger
import Observation

let repoStateChannel = Channel("RepoState")

@Observable
public class RepoState {
  public var sortedRepos: [Repo] = []
  public var passing: Int = 0
  public var failing: Int = 0
  public var running: Int = 0
  public var queued: Int = 0
  public var unreachable: Int = 0

  public func update(with model: Model, context: ViewContext) {
    repoStateChannel.log("updated")

    sortedRepos = model.repos(sortedBy: context.settings.sortMode)

    let set = NSCountedSet()
    sortedRepos.forEach({ set.add($0.state) })
    passing = set.count(for: Repo.State.passing)
    failing = set.count(for: Repo.State.failing) + set.count(for: Repo.State.partiallyFailing)
    running = set.count(for: Repo.State.running)
    queued = set.count(for: Repo.State.queued)
    unreachable = set.count(for: Repo.State.unknown)
  }

  public func repoIDs(atOffets offsets: IndexSet) -> [UUID] {
    offsets.map { sortedRepos[$0].id }
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
