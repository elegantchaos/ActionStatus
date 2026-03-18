// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/03/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// The current state of GitHub authentication within a session.
///
/// Published by `AuthService` as the single source of truth for auth state.
/// All UI and service coordination that depends on auth should derive its
/// behaviour from this enum rather than maintaining parallel state.
public enum GithubAuthState: Equatable, Sendable {
  /// No credentials are stored; the user has not signed in.
  case signedOut
  /// Stored credentials are being validated against the GitHub API at startup.
  case validating(GithubCredentials)
  /// The device-code flow has been initiated but the browser page is not yet open.
  case signingIn
  /// The user must enter the code at the verification URL to complete sign-in.
  case awaitingApproval(userCode: String, url: URL)
  /// Credentials have been validated and are ready for use.
  case signedIn(GithubCredentials)
  /// Stored credentials exist but failed validation; they are retained until the user signs out.
  case invalidCredentials(GithubCredentials)
  /// The sign-in flow failed with an error message suitable for display.
  case failed(String)
}

public extension GithubAuthState {
  /// The validated credentials when the state is `.signedIn`, otherwise `nil`.
  var credentials: GithubCredentials? {
    if case .signedIn(let credentials) = self { return credentials }
    return nil
  }

  /// `true` when credentials have been successfully validated this session.
  var isSignedIn: Bool { credentials != nil }
}
