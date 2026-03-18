// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/03/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Persists and retrieves the timestamp of the last observed GitHub event for a repository.
///
/// `OctoidRefreshController` uses this to avoid reprocessing events it has already seen.
/// The protocol decouples the Core refresh layer from any concrete storage mechanism;
/// `UserDefaultsLastEventStore` provides the live implementation in CoreUI, while tests
/// can supply an in-memory stub without touching UserDefaults.
///
/// Methods are async to allow conformers to delegate to actor-isolated storage
/// (e.g., `UserDefaults` on the main actor) without violating Swift 6 concurrency rules.
public protocol LastEventStore: Sendable {
  /// Returns the timestamp of the last observed event for the given key, or the reference date if none is stored.
  func lastEvent(forKey key: String) async -> Date
  /// Persists the timestamp of the last observed event for the given key.
  func setLastEvent(_ date: Date, forKey key: String) async
}
