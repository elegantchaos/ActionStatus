// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Core

/// Provider for the shared settings service used by commands.
@MainActor
public protocol SettingsServiceProvider: CommandCentre {
  /// Service that stores UI and app preferences.
  var settingsService: SettingsService { get }
}

/// Provider for the shared launch service used by commands.
@MainActor
public protocol LaunchServiceProvider: CommandCentre {
  /// Service that opens URLs and reveals files.
  var launchService: LaunchService { get }
}

/// Provider for the shared sheet service used by commands.
@MainActor
public protocol SheetServiceProvider: CommandCentre {
  /// Service that controls presented sheets.
  var sheetService: SheetService { get }
}

/// Provider for the shared refresh service used by commands.
@MainActor
public protocol RefreshServiceProvider: CommandCentre {
  /// Service that controls status refresh behavior.
  var refreshService: RefreshService { get }
}
