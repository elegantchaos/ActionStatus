// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/03/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Foundation

/// `LastEventStore` implementation that persists timestamps in `UserDefaults.standard`.
///
/// This is the live implementation used by the full app. It must stay in CoreUI
/// so that Core services remain free of any `UserDefaults` dependency.
public struct UserDefaultsLastEventStore: LastEventStore {
  /// Creates the store; safe to create multiple instances (all share `UserDefaults.standard`).
  public init() {}

  /// Returns the stored timestamp for `key`, or the reference date if nothing is stored.
  public func lastEvent(forKey key: String) async -> Date {
    let seconds = UserDefaults.standard.double(forKey: key)
    guard seconds != 0 else { return Date(timeIntervalSinceReferenceDate: 0) }
    return Date(timeIntervalSinceReferenceDate: seconds)
  }

  /// Persists `date` as a `TimeInterval` for `key`.
  public func setLastEvent(_ date: Date, forKey key: String) async {
    UserDefaults.standard.set(date.timeIntervalSinceReferenceDate, forKey: key)
  }
}
