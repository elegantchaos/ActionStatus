// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/03/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Observation

/// Canned authentication scenarios for the simulated auth driver used in debug builds.
public enum AuthDebugScenario: String, CaseIterable, Identifiable, Sendable {
  case signedOut
  case validating
  case signingIn
  case awaitingApproval
  case signedIn
  case invalidCredentials
  case failed

  public var id: Self { self }

  /// User-visible label shown in the auth debug UI.
  public var title: String {
    switch self {
      case .signedOut:
        "Signed Out"
      case .validating:
        "Checking Authentication"
      case .signingIn:
        "Starting Sign-In"
      case .awaitingApproval:
        "Awaiting Approval"
      case .signedIn:
        "Signed In"
      case .invalidCredentials:
        "Invalid Credentials"
      case .failed:
        "Unexpected Error"
    }
  }

  /// Representative auth state used for the scenario.
  public var state: GithubAuthState {
    switch self {
      case .signedOut:
        .signedOut
      case .validating:
        .validating(Self.sampleCredentials)
      case .signingIn:
        .signingIn
      case .awaitingApproval:
        .awaitingApproval(userCode: "AB-CD", url: Self.approvalURL)
      case .signedIn:
        .signedIn(Self.sampleCredentials)
      case .invalidCredentials:
        .invalidCredentials(Self.sampleCredentials)
      case .failed:
        .failed("The simulated sign-in failed unexpectedly.")
    }
  }

  /// Maps a concrete auth state back to its matching debug scenario.
  public init(state: GithubAuthState) {
    switch state {
      case .signedOut:
        self = .signedOut
      case .validating:
        self = .validating
      case .signingIn:
        self = .signingIn
      case .awaitingApproval:
        self = .awaitingApproval
      case .signedIn:
        self = .signedIn
      case .invalidCredentials:
        self = .invalidCredentials
      case .failed:
        self = .failed
    }
  }

  static let sampleCredentials = GithubCredentials(
    login: "debug-user",
    server: "api.github.com",
    token: "debug-token"
  )

  static let approvalURL = URL(string: "https://github.com/login/device")!
}

/// Manages the GitHub authentication lifecycle for the app.
///
/// `AuthService` is the single observable auth surface for the application.
/// It owns the published `authState`, while delegating mode-specific behaviour
/// such as live Keychain persistence, fixed preview/test states, or simulated
/// debug scenarios to an internal driver object.
@Observable
@MainActor
public final class AuthService {
  /// The current authentication state. Updated on the main actor.
  public private(set) var authState: GithubAuthState

  @ObservationIgnored private let driver: any AuthDriver

  /// Creates the live auth service backed by Keychain and the GitHub device flow.
  ///
  /// - Parameters:
  ///   - clientID: The GitHub OAuth app client ID (from `Info.plist`).
  ///   - keychainID: A stable app-scoped string used as the Keychain server attribute.
  public convenience init(clientID: String, keychainID: String = "actionstatus.elegantchaos.com") {
    self.init(initialState: .signedOut, driver: LiveAuthDriver(clientID: clientID, keychainID: keychainID))
  }

  /// Creates an auth service with a fixed auth state for previews or test harnesses.
  public static func stub(initialState: GithubAuthState = .signedOut) -> AuthService {
    AuthService(initialState: initialState, driver: FixedAuthDriver(initialState: initialState))
  }

  /// Creates a simulated auth service whose state can be adjusted from debug UI.
  public static func simulated(initialScenario: AuthDebugScenario = .signedOut) -> AuthService {
    let driver = SimulatedAuthDriver(initialScenario: initialScenario)
    return AuthService(initialState: initialScenario.state, driver: driver)
  }

  init(initialState: GithubAuthState, driver: any AuthDriver) {
    authState = initialState
    self.driver = driver
  }

  /// Loads any persisted credentials and validates them against the GitHub API.
  public func startup() async {
    await driver.startup(for: self)
  }

  /// Initiates the GitHub Device Authorization OAuth flow for the given server.
  ///
  /// State transitions to `.signingIn`, then `.awaitingApproval`, then `.signedIn` or `.failed`.
  public func startSignIn(server: String, scopes: [String]) {
    driver.startSignIn(server: server, scopes: scopes, for: self)
  }

  /// Starts sign-in targeting `api.github.com` with standard read scopes.
  public func startSignIn() {
    startSignIn(server: "api.github.com", scopes: ["repo", "read:user"])
  }

  /// Discards persisted credentials and resets state to `.signedOut`.
  public func signOut() {
    driver.signOut(for: self)
  }

  /// Returns `true` when the active driver supports simulated auth scenarios.
  public var supportsDebugScenarios: Bool {
    driver.supportsDebugScenarios
  }

  /// The active debug scenario when running with the simulated auth driver.
  public var activeDebugScenario: AuthDebugScenario? {
    driver.activeDebugScenario
  }

  /// Applies a simulated auth scenario when the active driver supports it.
  public func apply(debugScenario: AuthDebugScenario) {
    driver.apply(debugScenario: debugScenario, for: self)
  }

  /// Updates the published auth state.
  func setAuthState(_ newState: GithubAuthState) {
    authState = newState
  }
}

/// Internal behaviour contract used by the concrete auth service.
@MainActor
protocol AuthDriver: AnyObject {
  func startup(for service: AuthService) async
  func startSignIn(server: String, scopes: [String], for service: AuthService)
  func signOut(for service: AuthService)

  var supportsDebugScenarios: Bool { get }
  var activeDebugScenario: AuthDebugScenario? { get }
  func apply(debugScenario: AuthDebugScenario, for service: AuthService)
}

extension AuthDriver {
  var supportsDebugScenarios: Bool { false }
  var activeDebugScenario: AuthDebugScenario? { nil }
  func apply(debugScenario _: AuthDebugScenario, for _: AuthService) {}
}
