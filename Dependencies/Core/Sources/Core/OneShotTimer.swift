// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 21/07/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

@MainActor
final class OneShotTimer {
  typealias Action = @MainActor @Sendable () -> Void
  var timer: Timer?

  func cancel() -> Bool {
    let cancelled = timer != nil
    timer?.invalidate()
    timer = nil
    return cancelled
  }

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
