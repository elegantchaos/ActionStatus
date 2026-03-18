import Foundation
import Keychain
import Testing

@testable import Core

// TODO: These tests were written against a SettingsService API that no longer exists.
// They will be rewritten in Phase 8 when credential storage moves fully to GithubAuthService.

@MainActor
struct SettingsServiceTests {
  /// Verifies that persisted GitHub credentials survive service recreation.
  @Test(.disabled("Stale API — rewrite in Phase 8"))
  func updateGithubCredentialsPersistsDefaultsAndToken() {}

  /// Verifies that signing out clears both defaults and keychain state.
  @Test(.disabled("Stale API — rewrite in Phase 8"))
  func clearGithubCredentialsRemovesStoredToken() {}
}
