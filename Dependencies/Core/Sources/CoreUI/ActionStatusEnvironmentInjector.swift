import Core
import SwiftUI

// MARK: - Environment key

/// Default stub used when no `AuthService` has been explicitly injected (e.g., in vanilla Xcode previews).
private struct AuthServiceKey: EnvironmentKey {
  static let defaultValue: any AuthService = StubAuthService()
}

extension EnvironmentValues {
  /// The active `AuthService` instance for the current environment.
  public var authService: any AuthService {
    get { self[AuthServiceKey.self] }
    set { self[AuthServiceKey.self] = newValue }
  }
}

// MARK: - Injector

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

  /// Refresh configuration injected into SwiftUI views.
  public let refreshConfig: StoredRefreshConfiguration

  /// Authentication service injected into SwiftUI views.
  public let authService: any AuthService

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
    refreshConfig: StoredRefreshConfiguration,
    authService: any AuthService,
    sheetService: SheetService
  ) {
    self.commander = commander
    self.modelService = modelService
    self.metadataService = metadataService
    self.settingsService = settingsService
    self.launchService = launchService
    self.statusService = statusService
    self.refreshService = refreshService
    self.refreshConfig = refreshConfig
    self.authService = authService
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
      .environment(refreshConfig)
      .environment(\.authService, authService)
      .environment(sheetService)
      .environment(commander)
  }
}
