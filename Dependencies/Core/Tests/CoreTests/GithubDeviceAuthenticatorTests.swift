// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Testing

@testable import Core

@MainActor
struct GithubDeviceAuthenticatorTests {
  /// Standard `api.github.com` is normalized to a plain HTTPS URL.
  @Test
  func normalizesGithubAPIHost() throws {
    let api = try GithubDeviceAuthenticator.normalizedAPIBaseURL(for: "api.github.com")
    let oauth = try GithubDeviceAuthenticator.oauthBaseURL(for: "api.github.com")
    #expect(api.absoluteString == "https://api.github.com")
    #expect(oauth.absoluteString == "https://github.com")
  }

  /// A custom server with a path component is preserved verbatim.
  @Test
  func preservesCustomAPIServerPath() throws {
    let api = try GithubDeviceAuthenticator.normalizedAPIBaseURL(for: "https://github.example.com/api/v3")
    let oauth = try GithubDeviceAuthenticator.oauthBaseURL(for: "https://github.example.com/api/v3")
    #expect(api.absoluteString == "https://github.example.com/api/v3")
    #expect(oauth.absoluteString == "https://github.example.com")
  }

  /// An `api.` prefix is stripped when constructing the OAuth host.
  @Test
  func dropsAPIPrefixForOAuthHost() throws {
    let oauth = try GithubDeviceAuthenticator.oauthBaseURL(for: "api.github.example.com")
    #expect(oauth.absoluteString == "https://github.example.com")
  }

  /// Device-auth errors expose actionable localized descriptions for the UI.
  @Test
  func localizedDescriptionsAreActionable() {
    #expect(GithubDeviceAuthError.invalidServer.localizedDescription == "The GitHub server address is invalid. Please check the server URL and try again.")
    #expect(GithubDeviceAuthError.accessDenied.localizedDescription == "Access to your GitHub account was denied. Please sign in again and approve the request.")
    #expect(GithubDeviceAuthError.expiredToken.localizedDescription == "The GitHub sign-in request expired before it was approved. Please start the sign-in process again.")
  }
}
