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

public struct SettingsSnapshot<each V> {
//  let values: (repeat (AppSettingKey<each V>, each V))
//  init(values: (repeat (AppSettingKey<each V>, each V))) {
//    self.values = values
//  }

  let values: (repeat (AppSettingKey<each V>, Any?))
  init(values: (repeat (AppSettingKey<each V>, Any?))) {
    self.values = values
  }

  public func print() {
    for v in repeat each values {
      Swift.print("\(v.0): \(v.1 ?? "<nil>")")
    }
    
  }
}

//  func snapshot<each V>(key: repeat AppSettingKey<each V>) -> [String: Any] {
//    var result: [String: Any] = [:]
//    for k in repeat each key {
//      if let v = UserDefaults.standard.value(forKey: k) {
//        result[k.key] = v
//      }
//    }
//    return result
//  }


public extension UserDefaults {
  func snapshot<each V>(for keys: repeat AppSettingKey<each V>) -> SettingsSnapshot<repeat each V> {
//    var result: [String: Any] = [:]
//    for k in repeat each keys {
//      if object(forKey: k.key) != nil {
//        result[k.key] = value(forKey: k)
//      }
//    }
    return SettingsSnapshot(
      values: (repeat (each keys, value(forKey: each keys)))
    )
  }
  
  func restore<each V>(
    from snapshot: SettingsSnapshot<repeat each V>
  ) {
    for v in repeat each snapshot.values {
      set(v.1, forKey: v.0.key)
    }
  }
  
}
