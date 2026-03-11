import SwiftUI

/// Shared environment injector used by the live app and preview runtime.
@MainActor
public struct ActionStatusEnvironmentInjector: ViewModifier {
  /// Command centre injected into SwiftUI views.
  public let commander: ActionStatusCommander

  /// Model service injected into SwiftUI views.
  public let modelService: ModelService

  /// Metadata service injected into SwiftUI views.
  public let metadataService: MetadataService

  /// Settings service injected into SwiftUI views.
  public let settingsService: SettingsService

  /// Launch service injected into SwiftUI views.
  public let launchService: LaunchService

  /// Status service injected into SwiftUI views.
  public let statusService: StatusService

  /// Refresh service injected into SwiftUI views.
  public let refreshService: RefreshService

  /// Sheet service injected into SwiftUI views.
  public let sheetService: SheetService

  /// Creates an injector for the supplied services.
  public init(
    commander: ActionStatusCommander,
    modelService: ModelService,
    metadataService: MetadataService,
    settingsService: SettingsService,
    launchService: LaunchService,
    statusService: StatusService,
    refreshService: RefreshService,
    sheetService: SheetService
  ) {
    self.commander = commander
    self.modelService = modelService
    self.metadataService = metadataService
    self.settingsService = settingsService
    self.launchService = launchService
    self.statusService = statusService
    self.refreshService = refreshService
    self.sheetService = sheetService
  }

  /// Applies the shared ActionStatus environment graph.
  public func body(content: Content) -> some View {
    content
      .environment(modelService)
      .environment(metadataService)
      .environment(settingsService)
      .environment(launchService)
      .environment(statusService)
      .environment(refreshService)
      .environment(sheetService)
      .environment(commander)
  }
}
