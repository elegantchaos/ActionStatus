// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import DictionaryCoding
import Foundation
import Logger

let ubiquitousChannel = Channel("Ubiquitous Store")

/// Model store backed by an NSUbiquitousKeyValueStore.
public struct UbiquitousStore: ModelStore {
  /// The underlying iCloud key-value store.
  let store: NSUbiquitousKeyValueStore
  /// Key used to store the ordered list of repo IDs (the index).
  let indexKey: String
  /// Notification observer that reloads the model when the store changes externally.
  let observer: Observer

  /// Creates the store, optionally using a custom index key; defaults to `"State"` (or `"StateDebug"` in DEBUG builds).
  public init(key: String? = nil) {
    store = NSUbiquitousKeyValueStore.default
    observer = Observer()
    indexKey = key ?? Self.defaultKey
    store.synchronize()

    ubiquitousChannel.log("Initialized store with index \(index)")
  }

  /// Ordered list of repo IDs used to enumerate the store; backed by the ubiquitous store itself.
  private var index: [String] {
    get { (store.array(forKey: indexKey) as? [String]) ?? [] }
    set { store.set(newValue, forKey: indexKey) }
  }

  /// All repos currently in the store, decoded on demand; writing replaces the full set.
  public var values: [String: Repo] {
    get { readValues() }
    set { writeValues(newValue) }
  }
  
  /// Reads all repos from the ubiquitous store using the current index.
  private func readValues() -> Values {
    return .init(
      uniqueKeysWithValues:
        index.compactMap { id in
          get(forKey: id).map { (id, $0) }
        }
    )
  }
  
  /// Replaces the full set of repos, removing stale entries from the index.
  private mutating func writeValues(_ newValues: Values) {
    let oldIndex = index
    index = Array(newValues.keys)
    let removedIDs = Set(oldIndex).subtracting(Set(index))
    for id in removedIDs {
      remove(forKey: id)
    }
    for repo in newValues.values {
      set(repo, forKey: repo.id)
    }
  }
  
  /// Returns the repo for `key`, or `nil` if absent or decode fails.
  public func get(forKey key: String) -> Repo? {
    guard let dict = store.dictionary(forKey: key) else {
      return nil
    }

    do {
      let decoder = Repo.dictionaryDecoder
      return try decoder.decode(Repo.self, from: dict)
    } catch {
      ubiquitousChannel.log("Failed to restore repo data from \(dict).\n\nError:\(error)")
      return nil
    }
  }

  /// Encodes and writes `repo` to the ubiquitous store, adding it to the index if needed.
  public func set(_ repo: Repo, forKey key: String) {
    let encoder = DictionaryEncoder()
    do {
      let dict = try encoder.encode(repo) as [String: Any]
      insertIntoIndex(key)
      store.set(dict, forKey: key)
      store.synchronize()
      ubiquitousChannel.log("Saved \(repo) to store.")
    } catch {
      ubiquitousChannel.log("Failed to encode repo \(repo).\n\nError:\(error)")
      return
    }
  }

  /// Removes the repo for `key` from the ubiquitous store and the index.
  public func remove(forKey key: String) {
    removeFromIndex(key)
    store.removeObject(forKey: key)
    store.synchronize()
    ubiquitousChannel.log("Removed repo with id \(key) from store.")
  }

  /// Appends `key` to the index if it is not already present.
  private func insertIntoIndex(_ key: String) {
    var keys = index
    guard !keys.contains(key) else { return }
    keys.append(key)
    store.set(keys, forKey: indexKey)
  }

  /// Removes `key` from the index.
  private func removeFromIndex(_ key: String) {
    store.set(index.filter { $0 != key }, forKey: indexKey)
  }

  public func onChange(_ callback: @escaping ChangeCallback) async {
    observer.clear()
    observer.add {
      await callback(readValues())
    }
    await callback(readValues())
  }

  /// The default index key; uses a separate key in DEBUG builds to avoid corrupting release data.
  private static var defaultKey: String {
    #if DEBUG
      "StateDebug"
    #else
      "State"
    #endif
  }
  
  /// Manages the `NSUbiquitousKeyValueStore` change notification observer.
  final class Observer {
    let nc = NotificationCenter.default
    var handle: NSObjectProtocol?

    /// Removes the current observer, if any.
    func clear() {
      if let handle {
        nc.removeObserver(handle)
      }
    }

    /// Registers a notification handler that fires the given closure on the main actor.
    func add(perform: @escaping @MainActor @Sendable () async -> ()) {
      handle = NotificationCenter.default
        .addObserver(
          forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
          object: NSUbiquitousKeyValueStore.default,
          queue: .main,
        ) { _ in
          Task { @MainActor in
            ubiquitousChannel.log("store changed.")
            await perform()
          }
        }
    }
  }
}

nonisolated extension UbiquitousStore: TypedDebugDescription {
  public var debugLabel: String { indexKey }
}
