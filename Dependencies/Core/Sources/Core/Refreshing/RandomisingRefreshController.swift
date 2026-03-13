// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/05/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Randomly changes the state of repos. Useful for testing the UI.
@MainActor
public final class RandomisingRefreshController: RefreshController {
  internal let timer: OneShotTimer

  override public init(model: ModelService) {
    self.timer = OneShotTimer()
    super.init(model: model)
  }

  override func startRefresh() {
    refreshChannel.log("Resumed refresh.")
    timer.schedule(after: 0) { [weak self] in
      self?.doRefresh()
    }
  }

  override func cancelRefresh() {
    refreshChannel.log("Paused refresh.")
    if timer.cancel() {
      refreshChannel.log("Cancelled refresh.")
    }
  }
}

internal extension RandomisingRefreshController {
  func doRefresh() {
    switch state {
      case .running(let rate):
        refreshChannel.log("Completed Refresh")
        if let id = model.items.randomElement()?.value.id, let newState = Repo.State.allCases.randomElement() {
          model.updateState(newState, forRepoWithID: id)
        }

        timer.schedule(after: rate) { [weak self] in
          self?.doRefresh()
        }

      default:
        refreshChannel.log("Skipping Update (We Are Paused)")
    }
  }
}
