// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Application
import Combine
import Core
import Foundation
import Logger
import Observation
import SwiftUI

let repoStateChannel = Channel("RepoState")

@Observable
@MainActor public class StatusService {
  @ObservationIgnored private var modelService: ModelService?
  @ObservationIgnored private var observer: AnyCancellable?

  public var sortedRepos: [Repo] = []
  public var passing: Int = 0
  public var failing: Int = 0
  public var running: Int = 0
  public var queued: Int = 0
  public var dormant: Int = 0
  public var unreachable: Int = 0

  
  public init() {
  }

  public func connect(to modelService: ModelService) {
    @AppStorage(.sortMode) var sortMode

    self.modelService = modelService
    onChange(of: modelService.items) { [weak self] _ in
      self?.update(sortMode: sortMode)
    }
    
    onChange(of: sortMode) { [weak self] _ in
      self?.update(sortMode: sortMode)
    }
    
//    observer = UserDefaults.standard.onChanged { [self] in
//      update(sortMode: sortMode)
//    }
  }
  
  public func update(sortMode: SortMode) {
    repoStateChannel.log("updated")

    if let modelService {
      withAnimation {
        sortedRepos = sortMode.sort(modelService.items.values)
        
        let set = NSCountedSet()
        sortedRepos.forEach({ set.add($0.state) })
        passing = set.count(for: Repo.State.passing)
        failing = set.count(for: Repo.State.failing) + set.count(for: Repo.State.partiallyFailing)
        running = set.count(for: Repo.State.running)
        queued = set.count(for: Repo.State.queued)
        dormant = set.count(for: Repo.State.dormant)
        unreachable = set.count(for: Repo.State.unknown)
      }
    }
  }

  public func repoIDs(atOffets offsets: IndexSet) -> [String] {
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

    if dormant > 0 {
      state.append(.dormant)
    }

    if failing > 0 {
      state.append(.failing)
    }

    if state.count == 0 {
      if passing > 0 {
        state = [.passing]
      } else if dormant > 0 {
        state = [.dormant]
      } else {
        state = [.unknown]
      }
    }
    return state
  }
}
