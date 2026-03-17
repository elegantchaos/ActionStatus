// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Application
import Foundation
import Keychain
import Logger
import Observation
import Settings

public let settingsChannel = Channel("Settings")

/// Service that manages user-configurable settings.
@Observable
@MainActor
public final class SettingsService {
  
  /// Whether editing UI is currently enabled.
  public var isEditing = false

  public init() {
  }
  
  /// Toggles editing mode and returns the new state.
  public func toggleEditing() -> Bool {
    isEditing.toggle()
    return isEditing
  }

  /// Returns the configured navigation mode for the supplied trigger.
  public func repoNavigationMode(for trigger: CommandTrigger) -> NavigationMode {
    let defaults = UserDefaults.standard
    return switch trigger {
      case .primary:
        defaults.value(forKey: .navigationMode)
      case .secondary:
        defaults.value(forKey: .secondaryNavigationMode)
      case .tertiary:
        defaults.value(forKey: .tertiaryNavigationMode)
    }
  }

}


@MainActor public extension AppSettingKey where Value == NavigationMode {
  /// UserDefaults key for the default repository navigation action.
  static let navigationMode = AppSettingKey("NavigationMode", defaultValue: .edit)
  /// UserDefaults key for the secondary repository navigation action.
  static let secondaryNavigationMode = AppSettingKey("SecondaryNavigationMode", defaultValue: .viewRepo)
  /// UserDefaults key for the tertiary repository navigation action.
  static let tertiaryNavigationMode = AppSettingKey("TertiaryNavigationMode", defaultValue: .viewWorkflows)
}
