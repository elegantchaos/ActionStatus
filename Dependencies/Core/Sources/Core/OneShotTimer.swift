// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 21/07/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// A one-shot `Timer` wrapper confined to the main actor.
///
/// Wraps `Timer.scheduledTimer` so callers do not need to manage invalidation directly.
/// Cancelling before firing returns `true`; a second cancel on an already-nil timer returns `false`.
@MainActor
final class OneShotTimer {
  /// Closure type invoked when the timer fires.
  typealias Action = @MainActor @Sendable () -> Void
  /// The underlying `Timer`, or `nil` when idle.
  var timer: Timer?

  /// Cancels any pending timer. Returns `true` if a timer was active, `false` otherwise.
  func cancel() -> Bool {
    let cancelled = timer != nil
    timer?.invalidate()
    timer = nil
    return cancelled
  }

  /// Schedules `action` to fire once after `interval` seconds, cancelling any prior timer.
  func schedule(after interval: TimeInterval, action: @escaping Action) {
    _ = cancel()
    modelChannel.log("Scheduled refresh for \(interval) seconds.")
    timer = .scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
      MainActor.assumeIsolated {
        self?.timer = nil
        action()
      }
    }
  }
}
