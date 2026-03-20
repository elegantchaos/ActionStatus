// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 21/07/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Logger

/// Logger channel for refresh lifecycle events.
public let refreshChannel = Channel("com.elegantchaos.actionstatus.Refresh")

/// Tracks whether the refresh controller is actively polling or deliberately paused.
///
/// Pausing is reference-counted: each `pause()` increments the level and each
/// `resume(rate:)` decrements it, so nested pause/resume pairs balance correctly.
public enum RefreshState {
  /// Actively polling at the given interval in seconds.
  case running(Double)
  /// Paused with a reference count; polling resumes when the count reaches zero.
  case paused(Int)
}

/// Base class for all refresh controllers.
///
/// Manages the running/paused state machine and exposes `pause()` and `resume(rate:)`
/// to external callers. Subclasses implement the actual polling strategy by overriding
/// `startRefresh()`, `cancelRefresh()`, and optionally `refreshRateDidChange(to:)`.
///
/// The class is designed for inheritance rather than composition, so it is not `final`.
@MainActor
public class RefreshController {
  /// The model whose repository states this controller updates.
  internal let model: ModelService
  /// The current run/pause state of the controller.
  internal var state: RefreshState = .paused(1)

  /// Creates a controller bound to the given model service.
  public init(model: ModelService) {
    self.model = model
  }

  /// Starts polling. Must be overridden by subclasses.
  internal func startRefresh() { fatalError("needs overriding") }
  /// Stops polling. Must be overridden by subclasses.
  internal func cancelRefresh() { fatalError("needs overriding") }
  /// Called when the rate changes while already running; default is a no-op.
  internal func refreshRateDidChange(to _: Double) {}
}

public extension RefreshController {
  /// Increments the pause reference count, stopping active polling on the first call.
  func pause() {
    switch state {
      case .paused(let level):
        state = .paused(level + 1)
      case .running:
        state = .paused(1)
        cancelRefresh()
    }
  }

  /// Decrements the pause reference count, starting (or updating) polling when it reaches zero.
  func resume(rate: Double) {
    switch state {
      case .paused(let level):
        if level == 1 {
          state = .running(rate)
          startRefresh()
        } else {
          state = .paused(level - 1)
        }
      case .running(let currentRate):
        guard currentRate != rate else { break }
        state = .running(rate)
        refreshRateDidChange(to: rate)
    }
  }
}
