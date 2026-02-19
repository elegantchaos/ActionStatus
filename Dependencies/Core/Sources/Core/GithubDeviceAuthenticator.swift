// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/02/2026.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Logger

public let githubAuthChannel = Channel("com.elegantchaos.actionstatus.GithubAuth")

public struct GithubDeviceAuthorization {
  public let deviceCode: String
  public let userCode: String
  public let verificationURL: URL
  public let expiresIn: Int
  public let interval: Int
}

public enum GithubDeviceAuthError: Error {
  case missingClientID
  case invalidServer
  case invalidResponse
  case accessDenied
  case expiredToken
  case failed(String)
}

public struct GithubAuthenticatedUser {
  public let login: String
  public let token: String
}

public struct GithubDeviceAuthenticator {
  public let apiServer: String
  public let clientID: String
  private let session: URLSession

  public init(apiServer: String, clientID: String, session: URLSession = .shared) {
    self.apiServer = apiServer
    self.clientID = clientID
    self.session = session
  }

  public static func clientID(from bundle: Bundle = .main) -> String? {
    let value = bundle.object(forInfoDictionaryKey: "GithubOAuthClientID") as? String
    let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    return trimmed.isEmpty ? nil : trimmed
  }

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

  public func pollForUser(authorization: GithubDeviceAuthorization) async throws -> GithubAuthenticatedUser {
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
        return GithubAuthenticatedUser(login: login, token: token)
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

  static func normalizedAPIBaseURL(for server: String) throws -> URL {
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

  private struct AccessTokenResponse: Decodable {
    let accessToken: String?
    let error: String?

    enum CodingKeys: String, CodingKey {
      case accessToken = "access_token"
      case error
    }
  }

  private struct UserResponse: Decodable {
    let login: String
  }
}

private extension Array where Element == URLQueryItem {
  var formEncodedData: Data? {
    var components = URLComponents()
    components.queryItems = self
    return components.percentEncodedQuery?.data(using: .utf8)
  }
}
