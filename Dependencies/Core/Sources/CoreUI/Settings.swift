// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Foundation
import Keychain

import Settings

/// Boolean setting keys.
@MainActor public extension AppSettingKey where Value == Bool {
  /// UserDefaults key for the setting that controls whether we register a global hotkey.
  static let showInMenu = AppSettingKey("ShowInMenu", defaultValue: true)
  static let showInDock = AppSettingKey("ShowInDock", defaultValue: true)

}

@MainActor public extension AppSettingKey where Value == RefreshRate {
  static let refreshInterval = AppSettingKey("RefreshInterval", defaultValue: RefreshRate.automatic)
}

@MainActor public extension AppSettingKey where Value == SortMode {
  /// UserDefaults key for the sort mode setting.
  static let sortMode = AppSettingKey("SortMode", defaultValue: SortMode.state)
}



@MainActor public extension AppSettingKey where Value == DisplaySize {
  static let displaySize = AppSettingKey("DisplaySize", defaultValue: .automatic)
}

/// String setting keys.
@MainActor public extension AppSettingKey where Value == String {
  static let githubUser = AppSettingKey("GithubUser", defaultValue: "")
  static let githubServer = AppSettingKey("GithubServer", defaultValue: "api.github.com")

}

/// Data setting keys.
@MainActor public extension AppSettingKey where Value == Data {
  /// UserDefaults key for the hotkey combo data.
  static let hotKeyCombo = AppSettingKey("hotKeyCombo", defaultValue: Data())
}
