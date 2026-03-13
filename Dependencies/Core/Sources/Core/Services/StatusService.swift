// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Combine
import Foundation
import Logger
import Observation

let repoStateChannel = Channel("RepoState")

@Observable
@MainActor
public final class StatusService {
  @ObservationIgnored private let settingsService: SettingsService
  @ObservationIgnored private var defaultsObserver: AnyCancellable?
  @ObservationIgnored private var modelService: ModelService?

  public var sortedRepos: [Repo] = []
  public var passing = 0
  public var failing = 0
  public var running = 0
  public var queued = 0
  public var dormant = 0
  public var unreachable = 0

  public init(settingsService: SettingsService) {
    self.settingsService = settingsService
  }

  public func connect(to modelService: ModelService) {
    self.modelService = modelService

    observeChange(of: modelService.items) { [weak self] _ in
      self?.update(sortMode: self?.settingsService.sortMode ?? .state)
    }

    observeChange(of: self.settingsService.sortMode) { [weak self] sortMode in
      self?.update(sortMode: sortMode)
    }

    defaultsObserver = UserDefaults.standard.onActionStatusSettingsChanged { [weak self] in
      self?.update(sortMode: self?.settingsService.sortMode ?? .state)
    }
  }

  public func update(sortMode: SortMode) {
    repoStateChannel.log("updated")

    guard let modelService else { return }

    sortedRepos = sortMode.sort(modelService.items.values)

    let set = NSCountedSet()
    sortedRepos.forEach { set.add($0.state) }
    passing = set.count(for: Repo.State.passing)
    failing = set.count(for: Repo.State.failing) + set.count(for: Repo.State.partiallyFailing)
    running = set.count(for: Repo.State.running)
    queued = set.count(for: Repo.State.queued)
    dormant = set.count(for: Repo.State.dormant)
    unreachable = set.count(for: Repo.State.unknown)
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

    if state.isEmpty {
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
