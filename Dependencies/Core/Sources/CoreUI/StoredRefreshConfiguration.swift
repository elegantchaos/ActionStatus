// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Keychain
import Settings
import SwiftUI

@Observable
@MainActor
public class StoredRefreshConfiguration: RefreshConfiguration {
  @ObservationIgnored @AppStorage(.refreshInterval) public var refreshInterval
  @ObservationIgnored @AppStorage(.githubUser) public var githubUser
  @ObservationIgnored @AppStorage(.githubServer) public var githubServer

  init() {
  }

  public var isSignedIn: Bool {
    !githubUser.isEmpty && !githubServer.isEmpty && !githubToken.isEmpty
  }

  /// Reads the stored GitHub token.
  public var githubToken: String {
    get { readToken(for: githubUser, on: githubServer) }
    set { try! writeToken(newValue, for: githubUser, on: githubServer) }
  }

  /// Reads the stored GitHub token for the supplied account.
  public func readToken(for user: String, on server: String) -> String {
    guard !user.isEmpty, !server.isEmpty else {
      return ""
    }

    let token = try? Keychain.default.password(for: user, on: server)
    return token ?? ""
  }

  /// Persists a new GitHub token.
  public func writeToken(_ token: String) throws {
    try writeToken(token, for: githubUser, on: githubServer)
  }

  /// Persists a new GitHub token for the supplied account.
  public func writeToken(_ token: String, for user: String, on server: String) throws {
    guard !user.isEmpty, !server.isEmpty else {
      throw SettingsServiceError.missingGithubAccount
    }

    try Keychain.default.update(password: token, for: user, on: server)
  }

  /// Deletes the stored GitHub token for the current account.
  public func deleteToken() throws {
    try deleteToken(for: githubUser, on: githubServer)
  }

  /// Deletes the stored GitHub token for the supplied account.
  public func deleteToken(for user: String, on server: String) throws {
    guard !user.isEmpty, !server.isEmpty else {
      throw SettingsServiceError.missingGithubAccount
    }

    try Keychain.default.delete(passwordFor: user, on: server)
  }

  /// Persists the full GitHub account configuration and matching token.
  public func updateGithubCredentials(user: String, server: String, token: String) throws {
    let trimmedUser = user.trimmingCharacters(in: .whitespacesAndNewlines)
    let trimmedServer = server.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !trimmedUser.isEmpty, !trimmedServer.isEmpty else {
      throw SettingsServiceError.missingGithubAccount
    }

    try writeToken(token, for: trimmedUser, on: trimmedServer)

    githubUser = trimmedUser
    githubServer = trimmedServer
  }

  /// Clears the persisted GitHub account configuration and matching token.
  public func clearGithubCredentials() throws {
    let currentUser = githubUser
    let currentServer = githubServer

    if !currentUser.isEmpty, !currentServer.isEmpty {
      try deleteToken(for: currentUser, on: currentServer)
    }

    githubUser = AppSettingKey<String>.githubUser.defaultValue
    githubServer = AppSettingKey<String>.githubServer.defaultValue
  }
}

/// Errors thrown when persisted GitHub credentials cannot be managed.
public enum SettingsServiceError: Error {
  /// Indicates that a token operation was attempted without a complete account identity.
  case missingGithubAccount
}
