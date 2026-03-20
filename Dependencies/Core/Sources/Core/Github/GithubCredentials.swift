// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/03/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/// A set of validated GitHub credentials identifying a user on a specific server.
///
/// Value type passed through `GithubAuthState` and returned by `GithubDeviceAuthenticator.pollForUser`.
/// Carries all three components needed to make authenticated API requests.
public struct GithubCredentials: Equatable, Sendable {
  /// The user's GitHub login (username).
  public let login: String
  /// The GitHub API server this credential is valid for.
  public let server: String
  /// The OAuth access token for API requests.
  public let token: String

  /// Creates credentials with the given login, server, and token.
  public init(login: String, server: String, token: String) {
    self.login = login
    self.server = server
    self.token = token
  }
}
