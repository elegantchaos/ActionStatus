// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Application
import Foundation
import Logger

public let refreshServiceChannel = Channel("Refresh Service")

/// Service that manages status refresh scheduling and refresh controller creation.
///
/// The refresh type determines which controller is created; auth state determines
/// when it is created or destroyed. Call `connect(to:)` after startup to wire
/// an `AuthService` — the service observes auth-state changes and creates or
/// tears down the controller accordingly for all refresh types.
///
/// This decoupling allows `.random` mode to be paired with a `StubAuthService`
/// whose state can be changed at runtime to simulate the full auth state machine
/// in a running application.
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

  /// The configured refresh mode.
  public let type: RefreshType
  let modelService: ModelService
  let lastEventStore: any LastEventStore

  /// The current refresh interval applied to any active controller.
  var interval: RefreshRate

  /// The credential snapshot currently driving the refresh controller, or `nil` when signed out.
  var currentSettings: RefreshSettings?

  /// The currently active refresh controller, if any.
  var refreshController: RefreshController?

  /// Token that owns the auth-state observation loop; cancelled when the service is deallocated.
  @ObservationIgnored private var authObservationToken: ObservationToken?

  /// Creates a refresh service for the supplied model and refresh type.
  ///
  /// Call `connect(to:)` after startup to wire an auth service and start the
  /// controller lifecycle.
  public init(
    model: ModelService,
    type: RefreshType,
    interval: RefreshRate,
    lastEventStore: any LastEventStore
  ) {
    self.modelService = model
    self.type = type
    self.interval = interval
    self.lastEventStore = lastEventStore
  }

  /// Wires this service to an auth service, applying the current state immediately
  /// and observing future changes.
  ///
  /// Safe to call for all `RefreshType` values: `.normal` creates a GitHub controller
  /// on sign-in; `.random` creates a randomising controller; `.none` always produces
  /// no controller. Call this after `authService.startup()` and `modelService.startup()`
  /// so the initial auth state and model data are both available.
  public func connect(to authService: any AuthService) {
    applyAuthState(authService.authState)
    authObservationToken = onChange(of: authService.authState) { [weak self] newState in
      self?.applyAuthState(newState)
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

  /// Resumes refresh activity, starting the controller at the current interval.
  public func resumeRefresh() {
    refreshController?.resume(rate: interval.rate)
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

  /// Creates a GitHub-backed refresh controller using the current credential settings.
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

  /// Reacts to a new auth state by starting or stopping the refresh controller.
  ///
  /// On sign-in, creates a controller via `makeRefreshController()` (type-dispatched)
  /// so all refresh types respond uniformly to auth state. On sign-out or any
  /// non-signed-in state, tears down the active controller.
  private func applyAuthState(_ state: GithubAuthState) {
    switch state {
    case .signedIn(let credentials):
      let newSettings = RefreshSettings(server: credentials.server, token: credentials.token, interval: interval)
      guard newSettings != currentSettings else { return }
      currentSettings = newSettings
      resetRefresh()
      refreshController = makeRefreshController()
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
    case .normal: return "GitHub"
    case .random: return "Random"
    case .none: return "None"
    }
  }
}
