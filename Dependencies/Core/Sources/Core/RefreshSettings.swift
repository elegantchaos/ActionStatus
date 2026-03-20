// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/// The credential and rate snapshot used to drive a GitHub refresh controller.
///
/// Produced by `RefreshService` each time the auth state transitions to `.signedIn`.
/// Equality is checked before restarting the refresh controller to avoid unnecessary
/// teardowns when repeated observations produce identical values.
public struct RefreshSettings: Equatable, Sendable {
  /// GitHub API server hostname or URL, e.g. `"api.github.com"`.
  public let server: String

  /// Personal access token used for authenticated API calls.
  public let token: String

  /// The configured refresh rate.
  public let interval: RefreshRate

  /// Creates a refresh settings snapshot.
  public init(server: String, token: String, interval: RefreshRate) {
    self.server = server
    self.token = token
    self.interval = interval
  }
}
