// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/01/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Extensions for accessing AppSettingKey values through UserDefaults.
public extension UserDefaults {
  func value<V>(forKey key: AppSettingKey<V>) -> V where V: RawRepresentable {
    if let raw = object(forKey: key.key) as? V.RawValue, let value = V(rawValue: raw) {
      return value
    }
    return key.defaultValue
  }
  
  func set<V>(_ value: V, forKey key: AppSettingKey<V>) where V: RawRepresentable {
    set(value.rawValue, forKey: key.key)
  }

  func value<V>(forKey key: AppSettingKey<V>) -> V {
    let value = object(forKey: key.key) as? V
    return value ?? key.defaultValue
  }
  
  func set<V>(_ value: V, forKey key: AppSettingKey<V>) where V: SettingsCompatible {
    set(value, forKey: key.key)
  }
}

struct SettingsSnapshot {
//  func snapshot<each V>(key: repeat AppSettingKey<each V>) -> [String: Any] {
//    var result: [String: Any] = [:]
//    for k in repeat each key {
//      if let v = UserDefaults.standard.value(forKey: k) {
//        result[k.key] = v
//      }
//    }
//    return result
//  }
}

public extension UserDefaults {
  func snapshot<each V>(for keys: repeat AppSettingKey<each V>) -> [String: Any] {
    var result: [String: Any] = [:]
    for k in repeat each keys {
      if object(forKey: k.key) != nil {
        result[k.key] = value(forKey: k)
      }
    }
    return result
  }
  
  func restore<each V>(from snapshot: [String: Any], for keys: repeat AppSettingKey<each V>) {
    for k in repeat each keys {
      if let v = snapshot[k.key] {
        set(v, forKey: k.key)
      }
    }
  }
}
