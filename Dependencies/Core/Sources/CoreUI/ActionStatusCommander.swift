// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Core
import Observation

/// Command centre shared by the app runtime and preview runtime.
///
/// Views depend on this concrete commander instead of the full engine so the
/// same command surface can be used in previews and in the running app.
@Observable
@MainActor
public final class ActionStatusCommander {
  /// Model service used by model commands.
  public let modelService: ModelService

  /// Settings service used by UI commands.
  public let settingsService: SettingsService

  /// Launch service used by URL and file commands.
  public let launchService: LaunchService

  /// Refresh service used by views that pause and resume updates.
  public let refreshService: RefreshService

  /// Sheet service used by presentation commands.
  public let sheetService: SheetService

  /// Creates a commander backed by the supplied services.
  public init(
    modelService: ModelService,
    settingsService: SettingsService,
    launchService: LaunchService,
    refreshService: RefreshService,
    sheetService: SheetService
  ) {
    self.modelService = modelService
    self.settingsService = settingsService
    self.launchService = launchService
    self.refreshService = refreshService
    self.sheetService = sheetService
  }
}

extension ActionStatusCommander: CommandCentre {
}

extension ActionStatusCommander: LaunchServiceProvider {
}

extension ActionStatusCommander: ModelServiceProvider {
}

extension ActionStatusCommander: RefreshServiceProvider {
}

extension ActionStatusCommander: SettingsServiceProvider {
}

extension ActionStatusCommander: SheetServiceProvider {
}
