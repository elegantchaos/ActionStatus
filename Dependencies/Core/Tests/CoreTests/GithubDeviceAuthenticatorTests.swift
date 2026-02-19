import XCTest

@testable import Core

final class GithubDeviceAuthenticatorTests: XCTestCase {
  func testNormalizesGithubAPIHost() throws {
    let api = try GithubDeviceAuthenticator.normalizedAPIBaseURL(for: "api.github.com")
    let oauth = try GithubDeviceAuthenticator.oauthBaseURL(for: "api.github.com")

    XCTAssertEqual(api.absoluteString, "https://api.github.com")
    XCTAssertEqual(oauth.absoluteString, "https://github.com")
  }

  func testPreservesCustomAPIServerPath() throws {
    let api = try GithubDeviceAuthenticator.normalizedAPIBaseURL(for: "https://github.example.com/api/v3")
    let oauth = try GithubDeviceAuthenticator.oauthBaseURL(for: "https://github.example.com/api/v3")

    XCTAssertEqual(api.absoluteString, "https://github.example.com/api/v3")
    XCTAssertEqual(oauth.absoluteString, "https://github.example.com")
  }

  func testDropsAPIPrefixForOAuthHost() throws {
    let oauth = try GithubDeviceAuthenticator.oauthBaseURL(for: "api.github.example.com")
    XCTAssertEqual(oauth.absoluteString, "https://github.example.com")
  }
}
