// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/01/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Extensions for accessing AppSettingKey values through UserDefaults.
public extension UserDefaults {
  /// Returns a boolean value for the provided key.
  /// - Parameter key: The app setting key to look up.
  /// - Returns: The stored boolean value, or the key's default value if not set.
  func value(forKey key: AppSettingKey<Bool>) -> Bool {
    bool(forKey: key.key)
  }

  /// Sets a boolean value for the provided key.
  func set(_ value: Bool, forKey key: AppSettingKey<Bool>) {
    set(value, forKey: key.key)
  }

  /// Returns a data value for the provided key.
  /// - Parameter key: The app setting key to look up.
  /// - Returns: The stored data value, or the key's default value if not set.
  func value(forKey key: AppSettingKey<String>) -> String {
    string(forKey: key.key) ?? key.defaultValue
  }

  /// Sets a data value for the provided key.
  func set(_ value: String?, forKey key: AppSettingKey<String>) {
    set(value, forKey: key.key)
  }

  /// Returns a data value for the provided key.
  /// - Parameter key: The app setting key to look up.
  /// - Returns: The stored data value, or the key's default value if not set.
  func value(forKey key: AppSettingKey<Int>) -> Int {
    integer(forKey: key.key)
  }

  /// Sets a data value for the provided key.
  func set(_ value: Int?, forKey key: AppSettingKey<Int>) {
    set(value, forKey: key.key)
  }

  /// Returns a data value for the provided key.
  /// - Parameter key: The app setting key to look up.
  /// - Returns: The stored data value, or the key's default value if not set.
  func value(forKey key: AppSettingKey<Data>) -> Data? {
    data(forKey: key.key)
  }

  /// Sets a data value for the provided key.
  func set(_ value: Data?, forKey key: AppSettingKey<Data>) {
    set(value, forKey: key.key)
  }

  func value<V>(forKey key: AppSettingKey<V>) -> V? {
    nil
  }
}

struct SettingsSnapshot {
  func snapshot<each V>(key: repeat AppSettingKey<each V>) -> [String: Any] {
    var result: [String: Any] = [:]
    for k in repeat each key {
      if let v = UserDefaults.standard.value(forKey: k) {
        result[k.key] = v
      }
    }
    return result
  }
}

extension UserDefaults {
  func snapshot<each V>(key: repeat AppSettingKey<each V>) -> [String: Any] {
    var result: [String: Any] = [:]
    for k in repeat each key {
      if let v = UserDefaults.standard.value(forKey: k) {
        result[k.key] = v
      }
    }
    return result
  }
  
  func restore<each V>(from snapshot: [String: Any], key: repeat AppSettingKey<each V>) {
    for k in repeat each key {
      if let v = snapshot[k.key] {
        set(v, forKey: k.key)
      }
    }
  }
}
