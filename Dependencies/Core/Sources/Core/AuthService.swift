// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/03/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/// Manages the GitHub authentication lifecycle for the app.
///
/// Conforming types own the auth state machine, credential persistence,
/// and the device-code sign-in flow. All state changes are observable
/// via `authState` so that both services and UI can react without polling.
///
/// Only Engine (CoreUI) creates the live implementation; previews and tests
/// inject a `StubAuthService` with a canned initial state.
public protocol AuthService: AnyObject {
  /// The current authentication state. Observable — changes on the main actor.
  var authState: GithubAuthState { get }

  /// Loads any persisted credentials and validates them against the GitHub API.
  /// Call once during app startup before resuming refresh.
  func startup() async

  /// Initiates the GitHub Device Authorization OAuth flow for the given server.
  /// State transitions to `.signingIn`, then `.awaitingApproval`, then `.signedIn` or `.failed`.
  /// Safe to call from non-async contexts; the flow runs on an internal task.
  func startSignIn(server: String, scopes: [String])

  /// Discards persisted credentials and resets state to `.signedOut`.
  func signOut()
}
