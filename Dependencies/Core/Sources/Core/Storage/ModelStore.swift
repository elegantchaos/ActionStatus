// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Protocol for something that can save and load the model.
public protocol ModelStore: TypedDebugDescription {
  typealias Values = [String: Repo]

  /// Callback invoked when the store contents change externally.
  typealias ChangeCallback = @MainActor @Sendable (Values) async -> ()

  /// All repos currently held by the store.
  var values: Values { get set }

  /// Returns the repo stored under the given key, or `nil` if absent.
  func get(forKey: String) -> Repo?

  /// Persists a repo under the given key.
  func set(_ repo: Repo, forKey: String)

  /// Removes the repo stored under the given key.
  func remove(forKey: String)

  /// Registers a callback invoked whenever the store changes externally.
  /// The callback is also invoked once immediately with the current contents.
  mutating func onChange(_ perform: @escaping ChangeCallback) async
}
