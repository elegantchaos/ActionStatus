// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/01/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// A type-safe key for accessing UserDefaults values through AppStorage.
///
/// This type provides a strongly-typed wrapper around UserDefaults keys,
/// ensuring consistent key names and default values across the application.
public struct AppSettingKey<Value> {
  /// The string key used to store the value in UserDefaults.
  let key: String
  
  /// The default value to use when no value is stored.
  let defaultValue: Value

  /// Creates a new app setting key.
  /// - Parameters:
  ///   - key: The string key used in UserDefaults.
  ///   - defaultValue: The default value when no value is stored.
  public init(_ key: StringLiteralType, defaultValue: Value) {
    self.key = key
    self.defaultValue = defaultValue
  }
}

public extension AppSettingKey where Value == Bool {
  init(_ key: StringLiteralType, defaultValue: Bool = false) {
    self.key = key
    self.defaultValue = defaultValue
  }
}

public extension AppSettingKey {
  init<T>(_ key: StringLiteralType, defaultValue: T)  where T: RawRepresentable, T.RawValue == Value {
    self.key = key
    self.defaultValue = defaultValue.rawValue
  }
}
