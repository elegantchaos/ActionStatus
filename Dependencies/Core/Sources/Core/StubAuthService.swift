// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/03/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/// Fixed auth driver used by previews and test harnesses that need a stable auth state.
@MainActor
final class FixedAuthDriver: AuthDriver {
  private let initialState: GithubAuthState

  init(initialState: GithubAuthState) {
    self.initialState = initialState
  }

  func startup(for _: AuthService) async {}

  func startSignIn(server _: String, scopes _: [String], for _: AuthService) {}

  func signOut(for service: AuthService) {
    service.setAuthState(.signedOut)
  }

  var debugLabel: String {
    "fixed(\(AuthDebugScenario(state: initialState).rawValue))"
  }
}

/// Simulated auth driver used by debug builds to exercise auth-dependent UI.
@MainActor
final class SimulatedAuthDriver: AuthDriver {
  private var currentScenario: AuthDebugScenario

  init(initialScenario: AuthDebugScenario) {
    currentScenario = initialScenario
  }

  func startup(for service: AuthService) async {
    service.setAuthState(currentScenario.state)
  }

  func startSignIn(server _: String, scopes _: [String], for service: AuthService) {
    apply(debugScenario: .signingIn, for: service)
  }

  func signOut(for service: AuthService) {
    apply(debugScenario: .signedOut, for: service)
  }

  var supportsDebugScenarios: Bool { true }
  var activeDebugScenario: AuthDebugScenario? { currentScenario }

  func apply(debugScenario: AuthDebugScenario, for service: AuthService) {
    currentScenario = debugScenario
    service.setAuthState(debugScenario.state)
  }

  var debugLabel: String {
    "simulated(\(currentScenario.rawValue))"
  }
}
