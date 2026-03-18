// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Settings

@MainActor public extension AppSettingKey where Value == NavigationMode {
  /// UserDefaults key for the default repository navigation action.
  static let navigationMode = AppSettingKey("NavigationMode", defaultValue: .edit)
  /// UserDefaults key for the secondary repository navigation action.
  static let secondaryNavigationMode = AppSettingKey("SecondaryNavigationMode", defaultValue: .viewRepo)
  /// UserDefaults key for the tertiary repository navigation action.
  static let tertiaryNavigationMode = AppSettingKey("TertiaryNavigationMode", defaultValue: .viewWorkflows)
}
