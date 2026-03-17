// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Application
import Foundation
import Logger
import Observation
import Settings

let repoStateChannel = Channel("RepoState")

@Observable
@MainActor
public final class StatusService {
  @ObservationIgnored private var defaultsObserver: NotificationToken?
  @ObservationIgnored private var modelService: ModelService?
  @ObservationIgnored private var modelObservation: ObservationToken?

  public var sortedRepos: [Repo] = []
  public var passing = 0
  public var failing = 0
  public var running = 0
  public var queued = 0
  public var dormant = 0
  public var unreachable = 0

  public init() {
  }

  public func connect(to modelService: ModelService) {
    self.modelService = modelService

    modelObservation?.cancel()
    modelObservation = observeChange(of: modelService.items) { [weak self] _ in
      self?.update()
    }

    defaultsObserver = UserDefaults.standard.onActionStatusSettingsChanged { [weak self] in
      self?.update()
    }

    update()
  }

  public func update() {
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

  public func repoIDs(atOffsets offsets: IndexSet) -> [String] {
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

  var sortMode: SortMode {
    UserDefaults.standard.value(forKey: .sortMode)
  }
}

@MainActor public extension AppSettingKey where Value == SortMode {
  static let sortMode = AppSettingKey("SortMode", defaultValue: .state)
}
