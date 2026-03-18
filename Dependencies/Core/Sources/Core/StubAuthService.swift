// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/03/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Observation

/// A no-op `AuthService` that vends a fixed initial state.
///
/// Used in two places:
/// - **Previews**: `ActionStatusPreviewRuntime` creates a `StubAuthService` with
///   the desired `GithubAuthState` so views render without hitting Keychain or the network.
/// - **UI test injection**: when the `TEST_AUTH` environment variable is set, Engine
///   substitutes a `StubAuthService` for the live `GithubAuthService` so tests
///   can drive the UI from a known auth state.
///
/// All mutation methods (`startup`, `startSignIn`, `signOut`) are no-ops except
/// `signOut`, which resets the state to `.signedOut` so the sign-out path is testable.
@Observable
public final class StubAuthService: AuthService {

  /// The current authentication state.
  public private(set) var authState: GithubAuthState

  /// Creates a stub with the given initial state.
  /// - Parameter initialState: The state the stub will publish immediately. Defaults to `.signedOut`.
  public init(initialState: GithubAuthState = .signedOut) {
    self.authState = initialState
  }

  /// No-op — the stub never validates credentials.
  public func startup() async {}

  /// No-op — the stub does not run the device-code flow.
  public func startSignIn(server: String, scopes: [String]) {}

  /// Resets state to `.signedOut`.
  public func signOut() {
    authState = .signedOut
  }
}
