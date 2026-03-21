// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/03/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Keychain

/// Live auth driver that persists credentials to Keychain and runs the GitHub device flow.
@MainActor
final class LiveAuthDriver: AuthDriver {
  /// OAuth client ID read from `Info.plist`.
  private let clientID: String
  /// Keychain lookup server string — used as a stable app-scoped identifier.
  private let keychainID: String
  /// Task running the device-code sign-in flow, cancelled on sign-out.
  private var signInTask: Task<Void, Never>?

  init(clientID: String, keychainID: String) {
    self.clientID = clientID
    self.keychainID = keychainID
  }

  func startup(for service: AuthService) async {
    guard let credentials = loadCredentials() else { return }
    service.setAuthState(.validating(credentials))
    do {
      let authenticator = GithubDeviceAuthenticator(apiServer: credentials.server, clientID: clientID)
      let login = try await authenticator.validateToken(credentials.token)
      service.setAuthState(login == credentials.login ? .signedIn(credentials) : .invalidCredentials(credentials))
    } catch {
      githubAuthChannel.log("Token validation failed: \(error)")
      service.setAuthState(.invalidCredentials(credentials))
    }
  }

  func startSignIn(server: String, scopes: [String], for service: AuthService) {
    signInTask?.cancel()
    service.setAuthState(.signingIn)
    signInTask = Task { @MainActor [weak self, weak service] in
      guard let self, let service else { return }
      await performSignIn(server: server, scopes: scopes, for: service)
    }
  }

  func signOut(for service: AuthService) {
    signInTask?.cancel()
    signInTask = nil
    deleteCredentials()
    service.setAuthState(.signedOut)
  }

  var debugLabel: String { "live" }

  // MARK: - Private: sign-in flow

  private func performSignIn(server: String, scopes: [String], for service: AuthService) async {
    let authenticator = GithubDeviceAuthenticator(apiServer: server, clientID: clientID)
    do {
      let authorization = try await authenticator.startAuthorization(scopes: scopes)
      guard !Task.isCancelled else { return }
      service.setAuthState(.awaitingApproval(userCode: authorization.userCode, url: authorization.verificationURL))
      let credentials = try await authenticator.pollForUser(authorization: authorization)
      guard !Task.isCancelled else { return }
      persistCredentials(credentials)
      service.setAuthState(.signedIn(credentials))
    } catch {
      guard !Task.isCancelled else { return }
      githubAuthChannel.log("Sign-in failed: \(error)")
      service.setAuthState(.failed(error.localizedDescription))
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
