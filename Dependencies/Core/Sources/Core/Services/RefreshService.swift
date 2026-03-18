// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Logger
import Observation
import Settings

public let refreshServiceChannel = Channel("Refresh Service")

/// Service that manages status refresh scheduling and refresh controller creation.
///
/// For the `.normal` type the service observes `AuthService.authState` via
/// `withObservationTracking` and creates or tears down the GitHub refresh controller
/// whenever the user signs in or out. For `.random` and `.none` types (used in tests
/// and UI testing respectively) the controller is created directly on `startup()`.
@Observable
@MainActor
public final class RefreshService {
  /// Supported refresh modes.
  public enum RefreshType {
    /// Live GitHub-backed refresh, driven by auth state.
    case normal
    /// Randomises repo states without hitting GitHub — used in test builds.
    case random
    /// Disables all refresh — used in UI testing.
    case none
  }

  let type: RefreshType
  let modelService: ModelService
  let authService: any AuthService
  let lastEventStore: any LastEventStore

  /// The current refresh interval applied to any active controller.
  var interval: RefreshRate

  /// The credential snapshot currently driving the GitHub refresh controller, or `nil` when signed out.
  var currentSettings: RefreshSettings?

  var refreshController: RefreshController?

  /// Creates a refresh service for the supplied model, auth service, and metadata.
  public init(
    model: ModelService,
    metadata: MetadataService,
    authService: any AuthService,
    interval: RefreshRate,
    lastEventStore: any LastEventStore,
    forcedType: RefreshType? = nil
  ) {
    self.modelService = model
    self.authService = authService
    self.interval = interval
    self.lastEventStore = lastEventStore

    if let forcedType {
      self.type = forcedType
    } else if metadata.runtime.normalized(.testRefresh) == "random" {
      self.type = .random
    } else if metadata.isUITestingBuild {
      self.type = .none
    } else {
      self.type = .normal
    }
  }

  /// Starts the refresh service.
  ///
  /// For `.normal` type, begins observing auth state so the GitHub refresh controller
  /// is created when signed in and destroyed when signed out.
  /// For `.random` and `.none` types, creates and starts the controller immediately.
  public func startup() {
    switch type {
    case .normal:
      observeAuthState()
    case .random, .none:
      refreshController = makeRefreshController()
      refreshController?.resume(rate: interval.rate)
    }
  }

  /// Resets any active refresh controller.
  public func resetRefresh() {
    refreshServiceChannel.log("Reset")
    refreshController?.pause()
    refreshController = nil
  }

  /// Pauses refresh activity.
  public func pauseRefresh() {
    refreshServiceChannel.log("Paused")
    refreshController?.pause()
  }

  /// Resumes refresh activity.
  ///
  /// For `.normal` type, auth-state observation manages controller creation; only resumes an existing controller.
  /// For other types, creates the controller if needed before resuming.
  public func resumeRefresh() {
    switch type {
    case .normal:
      refreshController?.resume(rate: interval.rate)
    case .random, .none:
      if refreshController == nil {
        refreshController = makeRefreshController()
      }
      refreshController?.resume(rate: interval.rate)
    }
  }

  /// Updates the refresh interval and applies the new rate to any active controller.
  public func apply(interval: RefreshRate) {
    self.interval = interval
    refreshController?.resume(rate: interval.rate)
  }

  /// Creates the appropriate refresh controller for the configured mode.
  func makeRefreshController() -> RefreshController? {
    switch type {
    case .normal:
      return makeGithubRefreshController()
    case .random:
      return RandomisingRefreshController(model: modelService)
    case .none:
      refreshChannel.log("Refresh is disabled.")
      return nil
    }
  }

  /// Creates a GitHub-backed refresh controller when credentials are available.
  public func makeGithubRefreshController() -> RefreshController? {
    guard let settings = currentSettings, !settings.token.isEmpty else {
      githubChannel.log("No GitHub token configured.")
      return nil
    }

    return GithubRefreshController(
      model: modelService,
      token: settings.token,
      apiServer: settings.server,
      refreshInterval: settings.interval.rate,
      lastEventStore: lastEventStore
    )
  }

  // MARK: - Private

  /// Begins a recursive observation loop that reacts to `authService.authState` changes.
  private func observeAuthState() {
    withObservationTracking {
      applyAuthState(authService.authState)
    } onChange: {
      Task { @MainActor [weak self] in self?.observeAuthState() }
    }
  }

  /// Reacts to a new auth state by starting or stopping the GitHub refresh controller.
  private func applyAuthState(_ state: GithubAuthState) {
    switch state {
    case .signedIn(let credentials):
      let newSettings = RefreshSettings(server: credentials.server, token: credentials.token, interval: interval)
      guard newSettings != currentSettings else { return }
      currentSettings = newSettings
      resetRefresh()
      refreshController = makeGithubRefreshController()
      refreshController?.resume(rate: interval.rate)
    default:
      if currentSettings != nil {
        currentSettings = nil
        resetRefresh()
      }
    }
  }
}

extension RefreshService: TypedDebugDescription {
  public var debugLabel: String {
    switch type {
    case .normal:
      return "GitHub"
    case .random:
      return "Random"
    case .none:
      return "None"
    }
  }
}
