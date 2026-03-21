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
  @ObservationIgnored public let modelService: ModelService

  /// Shared settings service.
  @ObservationIgnored public let settingsService: SettingsService

  /// Shared launch service.
  @ObservationIgnored public let launchService: LaunchService

  /// Shared sheet service.
  @ObservationIgnored public let sheetService: SheetService

  /// Shared refresh service.
  @ObservationIgnored public let refreshService: RefreshService

  /// Shared authentication service.
  @ObservationIgnored public let authService: AuthService

  /// Shared status service.
  @ObservationIgnored public let statusService: StatusService

  /// Shared commander used by SwiftUI views and menus.
  @ObservationIgnored public let commander: ActionStatusCommander

  /// Environment injector used while the app is starting up and running.
  /// All services are safe to use before startup completes,
  /// and so we can use the same injector for startup and running states.
  @ObservationIgnored private let injector: ActionStatusEnvironmentInjector

  #if canImport(UIKit)
    /// Root view controller used for presenting UIKit UI.
    public var rootController: UIViewController?
  #endif

  /// Observer token for UserDefaults settings changes.
  @ObservationIgnored private var settingsObserver: NotificationToken?

  /// Runtime metadata used to configure startup behavior.
  @ObservationIgnored public let runtime: Runtime

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

    // Observe settings changes and push updated values to services.
    // This will trigger immediately with the initial values, so services are updated before the UI appears.
    settingsObserver = UserDefaults.standard.onChange(initial: true) { [weak self] defaults in
      guard let self else { return }
      let newSortMode = defaults.value(forKey: .sortMode)
      let newInterval = defaults.value(forKey: .refreshInterval)
      statusService.apply(sortMode: newSortMode)
      refreshService.apply(interval: newInterval)
    }
  }

  /// Creates the live engine and its shared services.
  public init(runtime: Runtime = .shared) {
    state = .uninitialised
    startupTask = nil
    self.runtime = runtime
    let settingsService = SettingsService()
    let statusService = StatusService()
    let sheetService = SheetService()
    let modelService = ModelService(runtime: runtime)
    statusService.connect(to: modelService)

    // Determine the refresh type from the runtime environment, then create
    // the matching auth service. Using an explicit type here keeps the wiring
    // visible and allows debug builds to pair any auth service with any controller.
    let refreshType = Self.makeRefreshType(runtime: runtime)

    let authService = Self.makeAuthService(runtime: runtime, refreshType: refreshType)

    let refreshService = RefreshService(
      model: modelService,
      type: refreshType,
      interval: UserDefaults.standard.value(forKey: .refreshInterval),
      lastEventStore: UserDefaultsLastEventStore()
    )

    let launchService = LaunchService()

    let commander = ActionStatusCommander(
      modelService: modelService,
      settingsService: settingsService,
      launchService: launchService,
      refreshService: refreshService,
      sheetService: sheetService
    )

    let injector = ActionStatusEnvironmentInjector(
      commander: commander,
      modelService: modelService,
      settingsService: settingsService,
      launchService: launchService,
      statusService: statusService,
      refreshService: refreshService,
      authService: authService,
      sheetService: sheetService
    )

    self.authService = authService
    self.statusService = statusService
    self.sheetService = sheetService
    self.modelService = modelService
    self.settingsService = settingsService
    self.refreshService = refreshService
    self.launchService = launchService
    self.commander = commander
    self.injector = injector

  }
}

public extension Engine {
  /// Resolves the refresh mode configuration for the supplied runtime.
  static func makeRefreshType(runtime: Runtime = .shared) -> RefreshService.RefreshType {
    switch runtime.normalized(.testRefresh) {
      case "random":
        return .random
      case "":
        if normalizedAuthMode(from: runtime).isEmpty == false {
          return .random
        } else if runtime.isUITestingBuild {
          return .none
        } else {
          return .normal
        }
      default:
        if runtime.isUITestingBuild {
          return .none
        } else {
          return .normal
        }
    }
  }

  /// Resolves the auth service configuration for the supplied runtime and refresh mode.
  static func makeAuthService(runtime: Runtime = .shared, refreshType: RefreshService.RefreshType) -> AuthService {
    let authMode = normalizedAuthMode(from: runtime)

    switch authMode {
      case "simulated":
        return AuthService.simulated()
      case "":
        switch refreshType {
          case .normal:
            let clientID = GithubDeviceAuthenticator.clientID(from: .main) ?? ""
            return AuthService(clientID: clientID)
          case .random:
            return AuthService.stub(initialState: .signedIn(GithubCredentials(login: "random-user", server: "api.github.com", token: "random-token")))
          case .none:
            return AuthService.stub(initialState: .signedOut)
        }
      default:
        return AuthService.stub(initialState: .signedIn(GithubCredentials(login: "test", server: "api.github.com", token: "test-token")))
    }
  }

  /// Returns the normalized auth mode string used for `TEST_AUTH`.
  static func normalizedAuthMode(from runtime: Runtime = .shared) -> String {
    let trimmed =
      runtime.environment(.testAuth)?
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .trimmingCharacters(in: CharacterSet(charactersIn: "\"'")) ?? ""
    return trimmed.lowercased()
  }
}

extension CGFloat {
  /// Standard inset/padding value used throughout ActionStatus UI.
  static let padding: CGFloat = 10
}

extension Engine: AppEngine {
  /// Returns the environment modifier used while the app is starting up.
  public var startupInjector: some ViewModifier { injector }

  /// Returns the environment modifier used while the app is running.
  public var runningInjector: some ViewModifier { injector }

  /// No-op retry hook; ActionStatus has no recoverable startup error path.
  public func retry() async throws {
  }

  /// Returns `false` — all errors are surfaced to the Application framework.
  public func shouldIgnore(error: any Error) -> Bool {
    false
  }
}
