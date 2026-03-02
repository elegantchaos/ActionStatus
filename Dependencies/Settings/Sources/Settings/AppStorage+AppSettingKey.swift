// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/01/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Extensions for creating AppStorage property wrappers with AppSettingKey.
public extension AppStorage {
  /// Creates an AppStorage property wrapper for a boolean value.
  /// - Parameters:
  ///   - key: The app setting key containing the key name and default value.
  ///   - store: The UserDefaults store to use (defaults to standard).
  init(_ key: AppSettingKey<Value>, store: UserDefaults? = nil) where Value == Bool {
    self.init(wrappedValue: key.defaultValue, key.key, store: store)
  }

  /// Creates an AppStorage property wrapper for an integer value.
  /// - Parameters:
  ///   - key: The app setting key containing the key name and default value.
  ///   - store: The UserDefaults store to use (defaults to standard).
  init(_ key: AppSettingKey<Value>, store: UserDefaults? = nil) where Value == Int {
    self.init(wrappedValue: key.defaultValue, key.key, store: store)
  }

  /// Creates an AppStorage property wrapper for a double value.
  /// - Parameters:
  ///   - key: The app setting key containing the key name and default value.
  ///   - store: The UserDefaults store to use (defaults to standard).
  init(_ key: AppSettingKey<Value>, store: UserDefaults? = nil) where Value == Double {
    self.init(wrappedValue: key.defaultValue, key.key, store: store)
  }

  /// Creates an AppStorage property wrapper for a string value.
  /// - Parameters:
  ///   - key: The app setting key containing the key name and default value.
  ///   - store: The UserDefaults store to use (defaults to standard).
  init(_ key: AppSettingKey<Value>, store: UserDefaults? = nil) where Value == String {
    self.init(wrappedValue: key.defaultValue, key.key, store: store)
  }

  /// Creates an AppStorage property wrapper for a URL value.
  /// - Parameters:
  ///   - key: The app setting key containing the key name and default value.
  ///   - store: The UserDefaults store to use (defaults to standard).
  init(_ key: AppSettingKey<Value>, store: UserDefaults? = nil) where Value == URL {
    self.init(wrappedValue: key.defaultValue, key.key, store: store)
  }

  /// Creates an AppStorage property wrapper for a date value.
  /// - Parameters:
  ///   - key: The app setting key containing the key name and default value.
  ///   - store: The UserDefaults store to use (defaults to standard).
  init(_ key: AppSettingKey<Value>, store: UserDefaults? = nil) where Value == Date {
    self.init(wrappedValue: key.defaultValue, key.key, store: store)
  }

  /// Creates an AppStorage property wrapper for a data value.
  /// - Parameters:
  ///   - key: The app setting key containing the key name and default value.
  ///   - store: The UserDefaults store to use (defaults to standard).
  init(_ key: AppSettingKey<Value>, store: UserDefaults? = nil) where Value == Data {
    self.init(wrappedValue: key.defaultValue, key.key, store: store)
  }
}
