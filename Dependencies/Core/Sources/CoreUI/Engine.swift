// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Application
import Core
import Logger
import Observation
import Runtime
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

    // Connect refresh to auth after both services have completed startup,
    // ensuring the initial auth state and model data are both available.
    refreshService.connect(to: authService)

    // Read initial settings values
    let defaults = UserDefaults.standard
    let currentSortMode = defaults.value(forKey: .sortMode)
    let currentInterval = defaults.value(forKey: .refreshInterval)

    // Push initial values
    statusService.apply(sortMode: currentSortMode)
    refreshService.apply(interval: currentInterval)

    // Observe future UserDefaults changes and push updated values to services
    settingsObserver = defaults.onChanged { [weak self] in
      guard let self else { return }
      let newSortMode = defaults.value(forKey: .sortMode)
      let newInterval = defaults.value(forKey: .refreshInterval)
      statusService.apply(sortMode: newSortMode)
      refreshService.apply(interval: newInterval)
    }
  }

  /// Creates the live engine and its shared services.
  public init() {
    state = .uninitialised
    startupTask = nil

    let runtime = Runtime.shared
    let settingsService = SettingsService()
    let statusService = StatusService()
    let sheetService = SheetService()
    let modelService = ModelService(runtime: runtime)
    statusService.connect(to: modelService)

    // Determine the refresh type from the runtime environment, then create
    // the matching auth service. Using an explicit type here keeps the wiring
    // visible and allows debug builds to pair any auth service with any controller.
    let refreshType: RefreshService.RefreshType
    if runtime.normalized(.testRefresh) == "random" {
      refreshType = .random
    } else if runtime.isUITestingBuild {
      refreshType = .none
    } else {
      refreshType = .normal
    }

    let authService: any AuthService
    switch refreshType {
      case .normal:
        if ProcessInfo.processInfo.environment["TEST_AUTH"] != nil {
          authService = StubAuthService(initialState: .signedIn(GithubCredentials(login: "test", server: "api.github.com", token: "test-token")))
        } else {
          let clientID = GithubDeviceAuthenticator.clientID(from: .main) ?? ""
          authService = GithubAuthService(clientID: clientID)
        }
      case .random:
        // Stub with a signed-in state so the randomising controller starts immediately.
        // The stub can be driven via debug UI to simulate sign-out or other states.
        authService = StubAuthService(initialState: .signedIn(GithubCredentials(login: "random-user", server: "api.github.com", token: "random-token")))
      case .none:
        authService = StubAuthService(initialState: .signedOut)
    }

    let refreshService = RefreshService(
      model: modelService,
      type: refreshType,
      interval: UserDefaults.standard.value(forKey: .refreshInterval),
      lastEventStore: UserDefaultsLastEventStore()
    )
    let launchService = LaunchService()

    self.authService = authService
    self.statusService = statusService
    self.sheetService = sheetService
    self.modelService = modelService
    self.settingsService = settingsService
    self.refreshService = refreshService
    self.launchService = launchService
    self.commander = ActionStatusCommander(
      modelService: modelService,
      settingsService: settingsService,
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
