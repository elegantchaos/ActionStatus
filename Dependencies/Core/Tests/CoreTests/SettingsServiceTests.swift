import Foundation
import Keychain
import Testing

@testable import Core

@MainActor
struct SettingsServiceTests {
  /// Verifies that persisted GitHub credentials survive service recreation.
  @Test
  func updateGithubCredentialsPersistsDefaultsAndToken() throws {
    let (defaults, suiteName) = try #require(makeDefaults())
    let user = uniqueValue(prefix: "user")
    let server = "api.github.com"
    let token = uniqueValue(prefix: "token")

    defer {
      clearStoredCredentials(user: user, server: server, defaults: defaults, suiteName: suiteName)
    }

    let service = SettingsService(defaults: defaults)
    try service.updateGithubCredentials(user: user, server: server, token: token)

    let restored = SettingsService(defaults: defaults)
    #expect(restored.githubUser == user)
    #expect(restored.githubServer == server)
    #expect(restored.readToken() == token)
  }

  /// Verifies that signing out clears both defaults and keychain state.
  @Test
  func clearGithubCredentialsRemovesStoredToken() throws {
    let (defaults, suiteName) = try #require(makeDefaults())
    let user = uniqueValue(prefix: "user")
    let server = "api.github.com"
    let token = uniqueValue(prefix: "token")

    let service = SettingsService(defaults: defaults)
    try service.updateGithubCredentials(user: user, server: server, token: token)
    try service.clearGithubCredentials()

    let restored = SettingsService(defaults: defaults)
    #expect(restored.githubUser.isEmpty)
    #expect(restored.githubServer == ActionStatusSettingKey<String>.githubServer.defaultValue)
    #expect(restored.readToken(for: user, on: server).isEmpty)

    clearStoredCredentials(user: user, server: server, defaults: defaults, suiteName: suiteName)
  }

  private func makeDefaults() -> (UserDefaults, String)? {
    let suiteName = uniqueValue(prefix: "defaults")
    guard let defaults = UserDefaults(suiteName: suiteName) else {
      return nil
    }

    defaults.removePersistentDomain(forName: suiteName)
    return (defaults, suiteName)
  }

  private func clearStoredCredentials(user: String, server: String, defaults: UserDefaults, suiteName: String) {
    try? Keychain.default.delete(passwordFor: user, on: server)
    defaults.removePersistentDomain(forName: suiteName)
  }

  private func uniqueValue(prefix: String) -> String {
    "\(prefix)-\(UUID().uuidString)"
  }
}
