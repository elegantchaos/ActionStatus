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

/// Service that maintains sorted repo lists and aggregate pass/fail counts.
///
/// Receives a pushed `sortMode` from the Engine (CoreUI) rather than reading
/// `UserDefaults` directly, keeping this target free of UserDefaults coupling.
@Observable
@MainActor
public final class StatusService {
  @ObservationIgnored private var modelService: ModelService?
  @ObservationIgnored private var modelObservation: ObservationToken?

  public var sortedRepos: [Repo] = []
  public var passing = 0
  public var failing = 0
  public var running = 0
  public var queued = 0
  public var dormant = 0
  public var unreachable = 0

  /// The current sort mode applied when building `sortedRepos`.
  public var sortMode: SortMode = .state

  public init() {
  }

  /// Connects the service to a model, observing item changes for automatic updates.
  public func connect(to modelService: ModelService) {
    self.modelService = modelService

    modelObservation?.cancel()
    modelObservation = observeChange(of: modelService.items) { [weak self] _ in
      self?.update()
    }

    update()
  }

  /// Updates `sortedRepos` and aggregate counts from the current model.
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

  /// Applies a new sort mode and immediately re-sorts the current repo list.
  public func apply(sortMode: SortMode) {
    self.sortMode = sortMode
    update()
  }

  /// Returns the IDs of repos at the specified index offsets in the sorted list.
  public func repoIDs(atOffsets offsets: IndexSet) -> [String] {
    offsets.map { sortedRepos[$0].id }
  }

  /// The combined state set representing the overall health of all watched repos.
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
