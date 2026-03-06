// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Protocol for something that can save and load the model.
public protocol ModelStore {
  typealias Values = [String:Repo]
  
  /// Callback to indicate that the store contents have been changed externally.
  typealias ChangeCallback = @Sendable (Values) async -> ()

  /// Our values.
  var values: Values { get set }
  
  /// Get a repo for an id.
  func get(forKey: String) -> Repo?
  
  /// Store a repo for an id.
  func set(_ repo: Repo, forKey: String)
  
  /// Remove a repo for an id.
  func remove(forKey: String)

  /// Register a callback which is invoked if the store changes externally.
  mutating func onChange(_ perform: @escaping ChangeCallback) async
}
