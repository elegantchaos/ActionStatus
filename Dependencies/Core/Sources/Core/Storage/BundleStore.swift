// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// A read-only `ModelStore` backed by a JSON file in the app bundle.
///
/// Loads all repos at init time and holds them in memory. Mutations are reflected in
/// `values` only for the lifetime of the instance; they are not written back to disk.
/// Used for seeding the model from a test JSON fixture.
public final class BundleStore: ModelStore {
  /// The in-memory repo dictionary loaded from the bundle resource.
  public var values: Values
  /// The resource name used to locate the JSON file in the bundle.
  private let key: String

  /// Loads the JSON repo file named `key` from `bundle`, crashing if it is absent or malformed.
  public init(key: String, bundle: Bundle = Bundle.main) {
    self.key = key

    guard let url = bundle.url(forResource: key, withExtension: "json") else {
      fatalError("Missing RepoResource from \(key) in \(bundle)")
    }

    do {
      let data = try Data(contentsOf: url)
      let decoder = JSONDecoder()
      let decoded = try decoder.decode([String: Repo].self, from: data)
      values = decoded
    } catch {
      fatalError("Failed to decode RepoResource data \(key) in \(bundle)")
    }
  }

  public func get(forKey key: String) -> Core.Repo? {
    values[key]
  }

  public func set(_ repo: Core.Repo, forKey key: String) {
    values[key] = repo
  }

  public func remove(forKey key: String) {
    values.removeValue(forKey: key)

  }

  public func onChange(_ callback: @escaping ChangeCallback) async {
    await callback(values)
  }

}

nonisolated extension BundleStore: TypedDebugDescription {
  public var debugLabel: String { key }
}
