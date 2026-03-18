// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Application
import Foundation
import Logger
import Observation

/// Logger channel for settings-related events.
public let settingsChannel = Channel("Settings")

/// Service that manages user-configurable settings.
@Observable
@MainActor
public final class SettingsService {

  /// Whether editing UI is currently enabled.
  public var isEditing = false

  /// Creates an idle settings service with default values.
  public init() {
  }

  /// Toggles editing mode and returns the new state.
  public func toggleEditing() -> Bool {
    isEditing.toggle()
    return isEditing
  }

}
