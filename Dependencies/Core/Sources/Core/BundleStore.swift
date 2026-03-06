// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class BundleStore: ModelStore {
  public var values: Values
  private let key: String

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
