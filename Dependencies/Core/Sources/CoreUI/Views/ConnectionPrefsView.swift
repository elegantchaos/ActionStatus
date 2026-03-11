// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import LoggerUI
import SwiftUI

struct ConnectionPrefsView: View {
  @Environment(LaunchService.self) private var launchService

  private let defaultGithubServer = "api.github.com"

  @State var token: String
  @State private var authState: GithubAuthUIState
  @State private var authTask: Task<Void, Never>? = nil
  @State private var healthTask: Task<Void, Never>? = nil
  @State private var authHealth: GithubAuthHealth = .unknown
  @State private var showCustomServerSettings = false
  
  @AppStorage(.githubUser) var githubUser
  @AppStorage(.githubServer) var githubServer
  
  private let initialAuthState: GithubAuthUIState?

  init(token: String, initialAuthState: GithubAuthUIState? = nil) {
    _token = .init(initialValue: token)
    _authState = State(initialValue: initialAuthState ?? .idle)
    self.initialAuthState = initialAuthState
  }

  var body: some View {
    return PreferencesSection(title: "Account") {
      AuthStatusBanner(state: authState, health: authHealth, currentUser: githubUser, hasToken: !token.isEmpty)

      HStack {
        if !isSignedIn {
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

        if isSignedIn {
          Button("Sign Out", role: .destructive, action: signOut)
            .disabled(!isSignedIn)
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
      refreshAuthHealth()
    }
    .onChange(of: authState) { _, _ in
      refreshAuthHealth()
    }
    .onChange(of: token) { _, _ in
      refreshAuthHealth()
    }
    .onChange(of: githubUser) { _, _ in
      refreshAuthHealth()
    }
    .onChange(of: githubServer) { _, _ in
      refreshAuthHealth()
    }
    .onDisappear {
      cancelSignIn()
      cancelHealthCheck()
    }
  }

  private var isSignedIn: Bool {
    !githubUser.isEmpty && !token.isEmpty
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

        await MainActor.run {
          authState = .awaitingApproval(authorization.userCode, authorization.verificationURL)
          launchService.open(url: authorization.verificationURL)
        }

        let authenticatedUser = try await authenticator.pollForUser(authorization: authorization)
        await MainActor.run {
          githubUser = authenticatedUser.login
          token = authenticatedUser.token
          authHealth = .healthy(authenticatedUser.login)
          authState = .signedIn(authenticatedUser.login)
          authTask = nil
        }
      } catch is CancellationError {
        await MainActor.run {
          authState = .idle
          authTask = nil
        }
      } catch {
        githubAuthChannel.log("Sign-in failed: \(error)")
        await MainActor.run {
          authState = .error(error.githubAuthMessage)
          authTask = nil
        }
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
    cancelHealthCheck()
    token = ""
    githubUser = ""
    authHealth = .unknown
    authState = .idle
  }

  func cancelHealthCheck() {
    healthTask?.cancel()
    healthTask = nil
  }

  func refreshAuthHealth() {
    cancelHealthCheck()
    guard isSignedIn else {
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
    let currentToken = token
    let currentUser = githubUser

    authHealth = .checking
    let authenticator = GithubDeviceAuthenticator(apiServer: server, clientID: "")
    healthTask = Task {
      do {
        let login = try await authenticator.validateToken(currentToken)
        await MainActor.run {
          if token == currentToken, githubUser == currentUser {
            authHealth = .healthy(login)
          }
          healthTask = nil
        }
      } catch is CancellationError {
        await MainActor.run {
          healthTask = nil
        }
      } catch {
        githubAuthChannel.log("Stored token check failed: \(error)")
        await MainActor.run {
          if token == currentToken, githubUser == currentUser {
            authHealth = .unhealthy(error.githubAuthMessage)
          }
          healthTask = nil
        }
      }
    }
  }
}

private struct AuthStatusBanner: View {
  let state: GithubAuthUIState
  let health: GithubAuthHealth
  let currentUser: String
  let hasToken: Bool

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
        if isSignedIn {
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
        guard isSignedIn else {
          return Text("Sign in to enable private repositories and notifications.")
        }

        switch health {
          case .unknown:
            return Text(currentUser)
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
        guard isSignedIn else { return "person.crop.circle.badge.exclamationmark" }
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
        guard isSignedIn else { return .secondary }
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

  private var isSignedIn: Bool {
    !currentUser.isEmpty && hasToken
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

//private struct ConnectionPrefsPreviewHarness: View {
//  @State var token: String
//  let state: GithubAuthUIState
//
//  init(token: String, state: GithubAuthUIState) {
//    _settings = State(initialValue: settings)
//    _token = State(initialValue: token)
//    self.state = state
//  }
//
//  var body: some View {
//    Form {
//      ConnectionPrefsView(token: $token, initialAuthState: state)
//    }
//  }
//}
//
//struct ConnectionPrefsView_Previews: PreviewProvider {
//  static var previews: some View {
//    Group {
//      injectPreview(title: "Default Server - Signed Out", settings: signedOutSettings(), token: "", state: .idle)
//      injectPreview(title: "Authenticating", settings: signedOutSettings(), token: "", state: .authenticating)
//      injectPreview(title: "Awaiting Approval", settings: signedOutSettings(), token: "", state: .awaitingApproval("ABCD-EFGH", URL(string: "https://github.com/login/device")!))
//      injectPreview(title: "Signed In", settings: signedInSettings(), token: "token", state: .signedIn("octocat"))
//      injectPreview(title: "Error", settings: signedOutSettings(), token: "", state: .error("Github sign-in failed: bad_verification_code"))
//      injectPreview(title: "Custom Server", settings: customServerSettings(), token: "", state: .idle)
//    }
//    .padding()
//  }
//
//  static func injectPreview(title: String, token: String, state: GithubAuthUIState) -> some View {
//    PreviewContext()
//      .inject(into: ConnectionPrefsPreviewHarness(token: token, state: state))
//      .previewDisplayName(title)
//  }
//
////  static func signedOutSettings() -> Settings {
////    var settings = Settings()
////    settings.githubServer = "api.github.com"
////    settings.githubUser = ""
////    return settings
////  }
////
////  static func signedInSettings() -> Settings {
////    var settings = Settings()
////    settings.githubServer = "api.github.com"
////    settings.githubUser = "octocat"
////    return settings
////  }
////
////  static func customServerSettings() -> Settings {
////    var settings = Settings()
////    settings.githubServer = "github.enterprise.example"
////    settings.githubUser = ""
////    return settings
////  }
//}
