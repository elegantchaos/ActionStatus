// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Application
import Core
import Logger
import Observation
import SwiftUI

#if canImport(UIKit)
  import UIKit
#endif

/// Logger channel for app monitoring lifecycle events.
public let monitoringChannel = Channel("Monitoring")

/// Main ActionStatus runtime engine.
///
/// The engine owns startup state and platform hooks, while `ActionStatusCommander`
/// exposes the reusable command and environment surface used by SwiftUI views.
@Observable
@MainActor
public final class Engine {
  /// The state of the engine.
  public var state: AppState

  /// Startup task tracked by the shared application loop.
  @ObservationIgnored public var startupTask: Task<Void, Never>?

  /// Shared model service.
  public let modelService: ModelService

  /// Shared settings service.
  public let settingsService: SettingsService

  /// Shared launch service.
  public let launchService: LaunchService

  /// Shared metadata service.
  public let metadataService: MetadataService

  /// Shared sheet service.
  public let sheetService: SheetService

  /// Shared refresh service.
  public let refreshService: RefreshService

  /// Shared authentication service.
  public let authService: any AuthService

  /// Shared status service.
  public let statusService: StatusService

  /// Shared commander used by SwiftUI views and menus.
  public let commander: ActionStatusCommander

  #if canImport(UIKit)
    /// Root view controller used for presenting UIKit UI.
    public var rootController: UIViewController?
  #endif

  /// Observer token for UserDefaults settings changes.
  @ObservationIgnored private var settingsObserver: NotificationToken?

  /// Performs one-time synchronous initialization.
  public func initialise() throws {
  }

  /// Performs asynchronous startup after initialization.
  public func startup() async throws {
    await authService.startup()
    await modelService.startup()
    refreshService.startup()

    // Push initial values
    let currentSortMode: SortMode = UserDefaults.standard.value(forKey: .sortMode)
    statusService.apply(sortMode: currentSortMode)
    let currentInterval: RefreshRate = UserDefaults.standard.value(forKey: .refreshInterval)
    refreshService.apply(interval: currentInterval)

    // Observe future UserDefaults changes and push updated values to services
    settingsObserver = UserDefaults.standard.onChanged { [weak self] in
      guard let self else { return }
      let newSortMode: SortMode = UserDefaults.standard.value(forKey: .sortMode)
      let newInterval: RefreshRate = UserDefaults.standard.value(forKey: .refreshInterval)
      statusService.apply(sortMode: newSortMode)
      refreshService.apply(interval: newInterval)
    }
  }

  /// Creates the live engine and its shared services.
  public init() {
    state = .uninitialised
    startupTask = nil

    let settingsService = SettingsService()
    let metadataService = MetadataService()
    let statusService = StatusService()
    let sheetService = SheetService()
    let modelService = ModelService(
      statusService: statusService,
      deviceIdentifier: metadataService.deviceIdentifier,
      source: metadataService.modelSource
    )

    let authService: any AuthService
    if ProcessInfo.processInfo.environment["TEST_AUTH"] != nil {
      authService = StubAuthService(initialState: .signedIn(GithubCredentials(login: "test", server: "api.github.com", token: "test-token")))
    } else {
      let clientID = GithubDeviceAuthenticator.clientID(from: .main) ?? ""
      authService = GithubAuthService(clientID: clientID)
    }

    let refreshService = RefreshService(
      model: modelService,
      metadata: metadataService,
      authService: authService,
      interval: UserDefaults.standard.value(forKey: .refreshInterval),
      lastEventStore: UserDefaultsLastEventStore()
    )
    let launchService = LaunchService()

    self.authService = authService
    self.statusService = statusService
    self.metadataService = metadataService
    self.sheetService = sheetService
    self.modelService = modelService
    self.settingsService = settingsService
    self.refreshService = refreshService
    self.launchService = launchService
    self.commander = ActionStatusCommander(
      modelService: modelService,
      settingsService: settingsService,
      metadataService: metadataService,
      launchService: launchService,
      refreshService: refreshService,
      sheetService: sheetService
    )
  }
}

extension CGFloat {
  /// Standard inset/padding value used throughout ActionStatus UI.
  static let padding: CGFloat = 10
}

extension Engine: AppEngine {
  /// Returns the environment modifier used while the app is starting up.
  public var startupInjector: some ViewModifier {
    ActionStatusEnvironmentInjector(
      commander: commander,
      modelService: modelService,
      metadataService: metadataService,
      settingsService: settingsService,
      launchService: launchService,
      statusService: statusService,
      refreshService: refreshService,
      authService: authService,
      sheetService: sheetService
    )
  }

  /// Returns the environment modifier used while the app is running.
  public var runningInjector: some ViewModifier {
    ActionStatusEnvironmentInjector(
      commander: commander,
      modelService: modelService,
      metadataService: metadataService,
      settingsService: settingsService,
      launchService: launchService,
      statusService: statusService,
      refreshService: refreshService,
      authService: authService,
      sheetService: sheetService
    )
  }

  /// No-op retry hook; ActionStatus has no recoverable startup error path.
  public func retry() async throws {
  }

  /// Returns `false` — all errors are surfaced to the Application framework.
  public func shouldIgnore(error: any Error) -> Bool {
    false
  }
}
