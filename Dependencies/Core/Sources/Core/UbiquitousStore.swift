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
  let store: NSUbiquitousKeyValueStore
  let indexKey: String
  let observer: Observer

  public init(key: String? = nil) {
    store = NSUbiquitousKeyValueStore.default
    observer = Observer()
    indexKey = key ?? Self.defaultKey
    store.synchronize()
  }

  private var index: [String] {
    get { (store.array(forKey: indexKey) as? [String]) ?? [] }
    set { store.set(newValue, forKey: indexKey) }
  }

  public var values: [String: Repo] {
    get { readValues() }
    set { writeValues(newValue) }
  }
  
  private func readValues() -> Values {
    return .init(
      uniqueKeysWithValues:
        index.compactMap { id in
          get(forKey: id).map { (id, $0) }
        }
    )
  }
  
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

  public func set(_ repo: Repo, forKey key: String) {
    let encoder = DictionaryEncoder()
    do {
      let dict = try encoder.encode(repo) as [String: Any]
      store.set(dict, forKey: key)
    } catch {
      ubiquitousChannel.log("Failed to encode repo \(repo).\n\nError:\(error)")
      return
    }
  }

  public func remove(forKey key: String) {
    store.removeObject(forKey: key)
  }

  public func onChange(_ callback: @escaping ChangeCallback) async {
    let nc = NotificationCenter.default
    // remove old observer if there is one
    observer.clear()

    // add an observer
    observer.add {
      await callback(readValues())
    }
        
    // make an initial call straight away and wait until it has completed
    await callback(readValues())
  }

  private static var defaultKey: String {
    #if DEBUG
      "StateDebug"
    #else
      "State"
    #endif
  }
  
  class Observer {
    let nc = NotificationCenter.default
    var handle: NSObjectProtocol?
    func clear() {
      // remove old observer if there is one
      if let handle {
        nc.removeObserver(handle)
      }
    }
    
    func add(perform: @escaping @Sendable () async -> ()) {
      handle = NotificationCenter.default
        .addObserver(
          forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
          object: NSUbiquitousKeyValueStore.default,
          queue: .main,
        ) { _ in Task { await perform() } }
    }
  }
}
