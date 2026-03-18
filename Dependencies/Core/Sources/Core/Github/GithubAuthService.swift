// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/03/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Keychain
import Observation

/// The live `AuthService` implementation that persists credentials to Keychain
/// and drives the GitHub Device Authorization OAuth flow.
///
/// Credential storage uses a single Keychain entry with a fixed lookup key
/// (account: `"github"`, server: `keychainID`). The full `GithubCredentials`
/// — login, server, and token — are encoded as JSON in the password field.
/// This avoids reading `UserDefaults` in Core: the service is self-contained.
///
/// On startup the service reads the Keychain entry, validates the stored token
/// via the GitHub API, and transitions the state machine accordingly. If
/// validation fails the credentials are retained as `.invalidCredentials` so
/// the user can sign out without losing context.
@Observable
public final class GithubAuthService: AuthService {

  // MARK: - Public state

  /// The current authentication state. Updated on the main actor.
  public private(set) var authState: GithubAuthState = .signedOut

  // MARK: - Private

  /// OAuth client ID read from `Info.plist`.
  private let clientID: String
  /// Keychain lookup server string — used as a stable app-scoped identifier.
  private let keychainID: String
  /// Task running the device-code sign-in flow, cancelled on sign-out.
  private var signInTask: Task<Void, Never>?

  // MARK: - Init

  /// Creates the service with the OAuth client ID and a Keychain identifier.
  ///
  /// - Parameters:
  ///   - clientID: The GitHub OAuth app client ID (from `Info.plist`).
  ///   - keychainID: A stable app-scoped string used as the Keychain server attribute.
  ///     Defaults to `"actionstatus.elegantchaos.com"`.
  public init(clientID: String, keychainID: String = "actionstatus.elegantchaos.com") {
    self.clientID = clientID
    self.keychainID = keychainID
  }

  // MARK: - AuthService

  /// Loads persisted credentials from Keychain and validates them against the GitHub API.
  @MainActor
  public func startup() async {
    guard let credentials = loadCredentials() else { return }
    authState = .validating(credentials)
    do {
      let authenticator = GithubDeviceAuthenticator(apiServer: credentials.server, clientID: clientID)
      let login = try await authenticator.validateToken(credentials.token)
      authState = login == credentials.login ? .signedIn(credentials) : .invalidCredentials(credentials)
    } catch {
      githubAuthChannel.log("Token validation failed: \(error)")
      authState = .invalidCredentials(credentials)
    }
  }

  /// Begins the device-code OAuth flow; transitions state asynchronously.
  @MainActor
  public func startSignIn(server: String, scopes: [String]) {
    signInTask?.cancel()
    authState = .signingIn
    signInTask = Task { @MainActor in
      await performSignIn(server: server, scopes: scopes)
    }
  }

  /// Clears persisted credentials and cancels any in-flight sign-in.
  @MainActor
  public func signOut() {
    signInTask?.cancel()
    signInTask = nil
    deleteCredentials()
    authState = .signedOut
  }

  // MARK: - Private: sign-in flow

  @MainActor
  private func performSignIn(server: String, scopes: [String]) async {
    let authenticator = GithubDeviceAuthenticator(apiServer: server, clientID: clientID)
    do {
      let authorization = try await authenticator.startAuthorization(scopes: scopes)
      guard !Task.isCancelled else { return }
      authState = .awaitingApproval(userCode: authorization.userCode, url: authorization.verificationURL)
      let credentials = try await authenticator.pollForUser(authorization: authorization)
      guard !Task.isCancelled else { return }
      persistCredentials(credentials)
      authState = .signedIn(credentials)
    } catch {
      guard !Task.isCancelled else { return }
      githubAuthChannel.log("Sign-in failed: \(error)")
      authState = .failed(error.localizedDescription)
    }
  }

  // MARK: - Private: Keychain

  /// JSON-encodable snapshot persisted to the Keychain password field.
  private struct StoredCredentials: Codable {
    let login: String
    let server: String
    let token: String
  }

  /// Fixed account name used for all Keychain lookups for this service.
  private var keychainAccount: String { "github" }

  /// Reads and decodes `StoredCredentials` from the Keychain; returns `nil` on any error.
  private func loadCredentials() -> GithubCredentials? {
    do {
      let json = try Keychain.default.password(for: keychainAccount, on: keychainID)
      guard let data = json.data(using: .utf8) else { return nil }
      let stored = try JSONDecoder().decode(StoredCredentials.self, from: data)
      return GithubCredentials(login: stored.login, server: stored.server, token: stored.token)
    } catch {
      return nil
    }
  }

  /// Encodes and writes `credentials` to the Keychain, updating an existing entry if present.
  private func persistCredentials(_ credentials: GithubCredentials) {
    let stored = StoredCredentials(login: credentials.login, server: credentials.server, token: credentials.token)
    guard
      let data = try? JSONEncoder().encode(stored),
      let json = String(data: data, encoding: .utf8)
    else { return }
    do {
      if (try? Keychain.default.password(for: keychainAccount, on: keychainID)) != nil {
        try Keychain.default.update(password: json, for: keychainAccount, on: keychainID)
      } else {
        try Keychain.default.add(password: json, for: keychainAccount, on: keychainID)
      }
    } catch {
      githubAuthChannel.log("Failed to persist credentials: \(error)")
    }
  }

  /// Removes the stored credential entry from the Keychain.
  private func deleteCredentials() {
    try? Keychain.default.delete(passwordFor: keychainAccount, on: keychainID)
  }
}
