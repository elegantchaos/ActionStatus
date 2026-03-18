// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import LoggerUI
import SwiftUI

struct ConnectionPrefsView: View {
  @Environment(LaunchService.self) private var launchService
  @Environment(StoredRefreshConfiguration.self) var refreshConfig
  private let defaultGithubServer = "api.github.com"

  @State private var authState: GithubAuthUIState
  @State private var authTask: Task<Void, Never>? = nil
  @State private var authHealth: GithubAuthHealth = .unknown
  @State private var showCustomServerSettings = false

  @AppStorage(.githubUser) var githubUser
  @AppStorage(.githubServer) var githubServer

  private let initialAuthState: GithubAuthUIState?

  init(initialAuthState: GithubAuthUIState? = nil) {
    _authState = State(initialValue: initialAuthState ?? .idle)
    self.initialAuthState = initialAuthState
  }

  var body: some View {
    return PreferencesSection(title: "Account") {
      AuthStatusBanner(state: authState, health: authHealth)

      HStack {
        if !refreshConfig.isSignedIn {
          Toggle("Custom Server", isOn: $showCustomServerSettings)
            .controlSize(.small)
            #if os(macOS)
              .toggleStyle(.checkbox)
            #endif

          if showCustomServerSettings {
            TextField(defaultGithubServer, text: $githubServer)
              .labelsHidden()
              #if !os(macOS)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
              #endif
          }
        }

        Spacer()

        if refreshConfig.isSignedIn {
          Button("Sign Out", role: .destructive, action: signOut)
            .disabled(!refreshConfig.isSignedIn)
        } else {
          Button(primaryAuthButtonTitle, action: primaryAuthButtonAction)
            .buttonStyle(.borderedProminent)
            .tint(primaryAuthButtonTint)
        }
      }
    }
    .onAppear {
      showCustomServerSettings = githubServer != defaultGithubServer
      if let initialAuthState {
        authState = initialAuthState
      }
    }
    .task(id: authHealthTaskKey) {
      await refreshAuthHealth()
    }
    .onDisappear {
      cancelSignIn()
    }
  }

  private var showsCancelAction: Bool {
    switch authState {
      case .authenticating, .awaitingApproval:
        return true
      case .idle, .signedIn, .error:
        return false
    }
  }

  private var primaryAuthButtonTitle: String {
    showsCancelAction ? "Cancel" : "Sign In with GitHub"
  }

  private var primaryAuthButtonTint: Color {
    showsCancelAction ? .orange : .accentColor
  }

  private var primaryAuthButtonAction: () -> Void {
    showsCancelAction ? cancelSignIn : startSignIn
  }

  private var normalizedGithubServer: String {
    let serverInput = githubServer.trimmingCharacters(in: .whitespacesAndNewlines)
    return serverInput.isEmpty ? defaultGithubServer : serverInput
  }

  private var authHealthTaskKey: AuthHealthTaskKey {
    AuthHealthTaskKey(
      token: refreshConfig.githubToken,
      githubUser: refreshConfig.githubUser,
      githubServer: refreshConfig.githubServer,
      authState: authState
    )
  }

  func startSignIn() {
    let server = normalizedGithubServer
    githubServer = server

    guard let clientID = GithubDeviceAuthenticator.clientID() else {
      authState = .error("Missing Github OAuth client id. Set GithubOAuthClientID in Info.plist build settings.")
      return
    }

    let authenticator = GithubDeviceAuthenticator(apiServer: server, clientID: clientID)
    authState = .authenticating

    authTask = Task {
      do {
        let authorization = try await authenticator.startAuthorization(scopes: [
          "repo"
        ])

        authState = .awaitingApproval(authorization.userCode, authorization.verificationURL)
        launchService.open(url: authorization.verificationURL)

        let credentials = try await authenticator.pollForUser(authorization: authorization)
        try refreshConfig.updateGithubCredentials(
          user: credentials.login,
          server: credentials.server,
          token: credentials.token
        )
        authHealth = .healthy(credentials.login)
        authState = .signedIn(credentials.login)
        authTask = nil
      } catch is CancellationError {
        authState = .idle
        authTask = nil
      } catch {
        githubAuthChannel.log("Sign-in failed: \(error)")
        authState = .error(error.githubAuthMessage)
        authTask = nil
      }
    }
  }

  func cancelSignIn() {
    authTask?.cancel()
    authTask = nil
    authState = .idle
  }

  func signOut() {
    cancelSignIn()
    refreshConfig.githubToken = ""

    do {
      try refreshConfig.clearGithubCredentials()
      authHealth = .unknown
      authState = .idle
    } catch {
      githubAuthChannel.log("Sign-out failed: \(error)")
      authState = .error("Failed to remove stored Github credentials.")
    }
  }

  func refreshAuthHealth() async {
    guard refreshConfig.isSignedIn else {
      authHealth = .unknown
      return
    }

    switch authState {
      case .authenticating, .awaitingApproval:
        return
      case .idle, .signedIn, .error:
        break
    }

    let server = normalizedGithubServer
    let currentToken = refreshConfig.githubToken
    let currentUser = githubUser

    authHealth = .checking
    let authenticator = GithubDeviceAuthenticator(apiServer: server, clientID: "")

    do {
      let login = try await authenticator.validateToken(currentToken)
      if refreshConfig.githubToken == currentToken, githubUser == currentUser {
        authHealth = .healthy(login)
      }
    } catch is CancellationError {
    } catch {
      githubAuthChannel.log("Stored token check failed: \(error)")
      if refreshConfig.githubToken == currentToken, githubUser == currentUser {
        authHealth = .unhealthy(error.githubAuthMessage)
      }
    }
  }
}

private struct AuthHealthTaskKey: Equatable {
  let token: String
  let githubUser: String
  let githubServer: String
  let authState: GithubAuthUIState
}

private struct AuthStatusBanner: View {
  @Environment(StoredRefreshConfiguration.self) var refreshConfig

  let state: GithubAuthUIState
  let health: GithubAuthHealth

  var body: some View {
    HStack(alignment: .top, spacing: 10) {
      Image(systemName: statusSymbol)
        .font(.headline)
        .foregroundStyle(statusColor)
        .padding(.top, 1)

      VStack(alignment: .leading, spacing: 4) {
        Text(statusTitle)
          .font(.headline)

        if let detail = statusDetail {
          detail
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
      }

      Spacer(minLength: 0)
    }
    .padding(12)
    .background(statusColor.opacity(0.12))
    .clipShape(.rect(cornerRadius: 10))
  }

  private var statusTitle: String {
    switch state {
      case .idle:
        if refreshConfig.isSignedIn {
          switch health {
            case .unknown, .checking:
              return "Signed In"
            case .healthy:
              return "Signed In"
            case .unhealthy:
              return "Signed In (Needs Attention)"
          }
        }
        return "Not Signed In"
      case .authenticating:
        return "Authorizing with GitHub"
      case .awaitingApproval:
        return "Approval Needed"
      case .signedIn(let user):
        return "Signed In as \(user)"
      case .error:
        return "Sign-In Failed"
    }
  }

  private var statusDetail: Text? {
    switch state {
      case .idle:
        guard refreshConfig.isSignedIn else {
          return Text("Sign in to enable private repositories and notifications.")
        }

        switch health {
          case .unknown:
            return Text(refreshConfig.githubUser)
          case .checking:
            return Text("Checking API access for stored credentials.")
          case .healthy(let login):
            return Text("Token is valid for \(login).")
          case .unhealthy(let message):
            return Text("Stored credentials are not currently usable: \(message)")
        }
      case .authenticating:
        return Text("Waiting for GitHub authorization to start.")
      case .awaitingApproval(let code, let url):
        return Text("Enter code \(code) [to complete sign-in](\(url)).")
      case .signedIn:
        return Text("Authentication is complete.")
      case .error(let message):
        return Text(message)
    }
  }

  private var statusSymbol: String {
    switch state {
      case .idle:
        guard refreshConfig.isSignedIn else { return "person.crop.circle.badge.exclamationmark" }
        switch health {
          case .unknown, .checking, .healthy:
            return "checkmark.circle.fill"
          case .unhealthy:
            return "exclamationmark.triangle.fill"
        }
      case .authenticating:
        return "hourglass.circle.fill"
      case .awaitingApproval:
        return "key.fill"
      case .signedIn:
        return "checkmark.circle.fill"
      case .error:
        return "xmark.octagon.fill"
    }
  }

  private var statusColor: Color {
    switch state {
      case .idle:
        guard refreshConfig.isSignedIn else { return .secondary }
        switch health {
          case .unknown, .healthy:
            return .green
          case .checking:
            return .orange
          case .unhealthy:
            return .red
        }
      case .authenticating, .awaitingApproval:
        return .orange
      case .signedIn:
        return .green
      case .error:
        return .red
    }
  }
}

enum GithubAuthHealth: Equatable {
  case unknown
  case checking
  case healthy(String)
  case unhealthy(String)
}

enum GithubAuthUIState: Equatable {
  case idle
  case authenticating
  case awaitingApproval(String, URL)
  case signedIn(String)
  case error(String)
}

private extension Error {
  var githubAuthMessage: String {
    guard let authError = self as? GithubDeviceAuthError else {
      return localizedDescription
    }

    switch authError {
      case .missingClientID:
        return "Missing Github OAuth client id."
      case .invalidServer:
        return "The configured Github server is invalid."
      case .invalidResponse:
        return "Github returned an unexpected response."
      case .accessDenied:
        return "Github sign-in was cancelled."
      case .expiredToken:
        return "Github sign-in timed out. Please try again."
      case .failed(let message):
        return "Github sign-in failed: \(message)"
    }
  }
}
