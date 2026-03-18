// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/02/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Logger

/// Logger channel for GitHub authentication events.
public let githubAuthChannel = Channel("com.elegantchaos.actionstatus.GithubAuth")

/// Authorization data returned by the device-code flow initiation step.
public struct GithubDeviceAuthorization {
  /// Opaque code sent to the token endpoint during polling.
  public let deviceCode: String
  /// Human-readable code the user enters at the verification URL.
  public let userCode: String
  /// URL where the user completes authorization in their browser.
  public let verificationURL: URL
  /// Seconds until the device code expires.
  public let expiresIn: Int
  /// Minimum polling interval in seconds.
  public let interval: Int
}

/// Errors that can occur during the GitHub Device Authorization OAuth flow.
public enum GithubDeviceAuthError: Error {
  /// No OAuth client ID was configured in the app bundle.
  case missingClientID
  /// The server string could not be resolved to a valid URL.
  case invalidServer
  /// The server returned an unexpected or malformed response.
  case invalidResponse
  /// The user explicitly denied the authorization request.
  case accessDenied
  /// The device code expired before the user completed authorization.
  case expiredToken
  /// An unexpected error was returned by the server.
  case failed(String)
}

/// A set of validated GitHub credentials identifying a user on a specific server.
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

/// Implements the GitHub Device Authorization Grant (RFC 8628) OAuth flow.
///
/// Handles the full lifecycle: requesting a device code, polling for user
/// authorization, and verifying a token against the GitHub API. Supports
/// both github.com and GitHub Enterprise Server endpoints.
public struct GithubDeviceAuthenticator {
  /// The GitHub API server hostname or base URL (e.g. `"api.github.com"`).
  public let apiServer: String
  /// The OAuth application client ID.
  public let clientID: String
  /// The URLSession used for all API requests.
  private let session: URLSession

  /// Creates an authenticator targeting the given server with the given client ID.
  public init(apiServer: String, clientID: String, session: URLSession = .shared) {
    self.apiServer = apiServer
    self.clientID = clientID
    self.session = session
  }

  /// Reads the OAuth client ID from the app bundle's `Info.plist` (`GithubOAuthClientID` key).
  /// Returns `nil` if the key is absent or blank.
  public static func clientID(from bundle: Bundle = .main) -> String? {
    let value = bundle.object(forInfoDictionaryKey: "GithubOAuthClientID") as? String
    let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    return trimmed.isEmpty ? nil : trimmed
  }

  /// Requests a device code from GitHub and returns authorization details for user display.
  /// The caller should show `userCode` and open `verificationURL` so the user can authorize.
  public func startAuthorization(scopes: [String]) async throws -> GithubDeviceAuthorization {
    guard !clientID.isEmpty else { throw GithubDeviceAuthError.missingClientID }
    let oauthBase = try Self.oauthBaseURL(for: apiServer)
    let endpoint = oauthBase.appending(path: "login/device/code")

    let scopeValue = scopes.joined(separator: " ")
    let body = [
      URLQueryItem(name: "client_id", value: clientID),
      URLQueryItem(name: "scope", value: scopeValue),
    ]

    let response: DeviceCodeResponse = try await postForm(endpoint: endpoint, body: body)
    guard let url = URL(string: response.verificationURI) else {
      throw GithubDeviceAuthError.invalidResponse
    }

    return GithubDeviceAuthorization(
      deviceCode: response.deviceCode,
      userCode: response.userCode,
      verificationURL: url,
      expiresIn: response.expiresIn,
      interval: max(response.interval, 1)
    )
  }

  /// Polls the GitHub token endpoint until the user authorizes, denies, or the device code expires.
  /// Respects the polling interval from the authorization response and handles slow-down requests.
  public func pollForUser(authorization: GithubDeviceAuthorization) async throws -> GithubCredentials {
    guard !clientID.isEmpty else { throw GithubDeviceAuthError.missingClientID }
    let oauthBase = try Self.oauthBaseURL(for: apiServer)
    let endpoint = oauthBase.appending(path: "login/oauth/access_token")

    var interval = max(authorization.interval, 1)
    let expiry = Date().addingTimeInterval(TimeInterval(authorization.expiresIn))

    while Date() < expiry {
      let body = [
        URLQueryItem(name: "client_id", value: clientID),
        URLQueryItem(name: "device_code", value: authorization.deviceCode),
        URLQueryItem(name: "grant_type", value: "urn:ietf:params:oauth:grant-type:device_code"),
      ]

      let response: AccessTokenResponse = try await postForm(endpoint: endpoint, body: body)
      if let token = response.accessToken, !token.isEmpty {
        let login = try await fetchUserLogin(token: token)
        return GithubCredentials(login: login, server: apiServer, token: token)
      }

      switch response.error {
        case "authorization_pending":
          try await Task.sleep(nanoseconds: UInt64(interval) * 1_000_000_000)
        case "slow_down":
          interval += 5
          try await Task.sleep(nanoseconds: UInt64(interval) * 1_000_000_000)
        case "access_denied":
          throw GithubDeviceAuthError.accessDenied
        case "expired_token":
          throw GithubDeviceAuthError.expiredToken
        case nil:
          throw GithubDeviceAuthError.invalidResponse
        case .some(let error):
          throw GithubDeviceAuthError.failed(error)
      }
    }

    throw GithubDeviceAuthError.expiredToken
  }

  /// Verifies that the given access token is valid by fetching the authenticated user's login.
  /// Returns the GitHub login name on success.
  public func validateToken(_ token: String) async throws -> String {
    guard !token.isEmpty else { throw GithubDeviceAuthError.failed("Missing token") }
    return try await fetchUserLogin(token: token)
  }

  /// Normalizes a server string into a base URL suitable for GitHub API requests.
  /// Accepts bare hostnames or full URLs; always returns a scheme + host with no trailing slash.
  public static func normalizedAPIBaseURL(for server: String) throws -> URL {
    let trimmed = server.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { throw GithubDeviceAuthError.invalidServer }

    if let url = URL(string: trimmed), let host = url.host {
      var components = URLComponents()
      components.scheme = url.scheme ?? "https"
      components.host = host
      components.path = url.path
      guard let resolved = components.url else { throw GithubDeviceAuthError.invalidServer }
      return resolved
    }

    var components = URLComponents()
    components.scheme = "https"
    components.host = trimmed
    guard let resolved = components.url else { throw GithubDeviceAuthError.invalidServer }
    return resolved
  }

  /// Derives the OAuth host URL from the API base URL.
  /// Maps `api.github.com` → `github.com` and strips `api.` prefixes for GHE servers.
  static func oauthBaseURL(for server: String) throws -> URL {
    let apiBase = try normalizedAPIBaseURL(for: server)
    guard let host = apiBase.host else { throw GithubDeviceAuthError.invalidServer }

    let oauthHost: String
    if host == "api.github.com" {
      oauthHost = "github.com"
    } else if host.hasPrefix("api.") {
      oauthHost = String(host.dropFirst(4))
    } else {
      oauthHost = host
    }

    var components = URLComponents()
    components.scheme = apiBase.scheme ?? "https"
    components.host = oauthHost
    guard let resolved = components.url else { throw GithubDeviceAuthError.invalidServer }
    return resolved
  }

  /// Calls the `/user` endpoint with Bearer authentication and returns the login name.
  private func fetchUserLogin(token: String) async throws -> String {
    let endpoint = try Self.normalizedAPIBaseURL(for: apiServer).appending(path: "user")
    var request = URLRequest(url: endpoint)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

    let (data, response) = try await session.data(for: request)
    guard let http = response as? HTTPURLResponse else { throw GithubDeviceAuthError.invalidResponse }
    guard (200...299).contains(http.statusCode) else {
      throw GithubDeviceAuthError.failed("Failed to fetch user: \(http.statusCode)")
    }

    let user = try JSONDecoder().decode(UserResponse.self, from: data)
    return user.login
  }

  /// Sends a URL-encoded form POST to the endpoint and decodes the JSON response.
  private func postForm<T: Decodable>(endpoint: URL, body: [URLQueryItem]) async throws -> T {
    var request = URLRequest(url: endpoint)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.httpBody = body.formEncodedData

    let (data, response) = try await session.data(for: request)
    guard let http = response as? HTTPURLResponse else { throw GithubDeviceAuthError.invalidResponse }
    guard (200...299).contains(http.statusCode) else {
      throw GithubDeviceAuthError.failed("Auth request failed: \(http.statusCode)")
    }

    return try JSONDecoder().decode(T.self, from: data)
  }

  /// JSON response from the device-code request endpoint.
  private struct DeviceCodeResponse: Decodable {
    let deviceCode: String
    let userCode: String
    let verificationURI: String
    let expiresIn: Int
    let interval: Int

    enum CodingKeys: String, CodingKey {
      case deviceCode = "device_code"
      case userCode = "user_code"
      case verificationURI = "verification_uri"
      case expiresIn = "expires_in"
      case interval
    }
  }

  /// JSON response from the access-token polling endpoint.
  private struct AccessTokenResponse: Decodable {
    let accessToken: String?
    let error: String?

    enum CodingKeys: String, CodingKey {
      case accessToken = "access_token"
      case error
    }
  }

  /// Minimal JSON response from the `/user` endpoint.
  private struct UserResponse: Decodable {
    let login: String
  }
}

private extension Array where Element == URLQueryItem {
  /// Encodes the query items as a URL percent-encoded form body.
  var formEncodedData: Data? {
    var components = URLComponents()
    components.queryItems = self
    return components.percentEncodedQuery?.data(using: .utf8)
  }
}
