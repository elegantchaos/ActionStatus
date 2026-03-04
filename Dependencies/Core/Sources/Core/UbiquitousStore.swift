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
  var observer: NSObjectProtocol?

  public init(key: String? = nil) {
    store = NSUbiquitousKeyValueStore.default
    indexKey = key ?? Self.defaultKey
    store.synchronize()
  }

  public func synchronize() -> Bool {
    store.synchronize()
  }

  public var index: [String] {
    get { (store.array(forKey: indexKey) as? [String]) ?? [] }
    set { store.set(newValue, forKey: indexKey) }
  }

  public func repo(forKey key: String) -> Repo? {
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

  public func store(_ repo: Repo, forKey key: String) -> Bool {
    let encoder = DictionaryEncoder()
    guard let dict = try? encoder.encode(repo) as [String: Any] else {
      return false
    }

    store.set(dict, forKey: key)
    return true
  }

  public func removeObject(forKey key: String) {
    store.removeObject(forKey: key)
  }

  public mutating func onChange(_ callback: @escaping ChangeCallback) {
    let nc = NotificationCenter.default
    if let observer {
      nc.removeObserver(observer)
    }
    observer = NotificationCenter.default
      .addObserver(
        forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
        object: NSUbiquitousKeyValueStore.default,
        queue: .main
      ) { _ in Task { await callback() } }
  }

  private static var defaultKey: String {
    #if DEBUG
      "StateDebug"
    #else
      "State"
    #endif
  }
}
