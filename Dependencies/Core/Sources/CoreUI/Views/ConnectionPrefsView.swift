// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import LoggerUI
import SwiftUI

/// View displaying the current GitHub authentication state and sign-in/sign-out controls.
///
/// Reads `authService` from the environment and drives all UI directly from
/// `GithubAuthState` — no separate health-check task or local state mirror needed.
struct ConnectionPrefsView: View {
  @Environment(\.authService) private var authService
  @Environment(LaunchService.self) private var launchService

  /// Default GitHub API server used when no custom server is entered.
  private let defaultGithubServer = "api.github.com"

  @State private var showCustomServerSettings = false
  @State private var customServer = ""

  var body: some View {
    PreferencesSection(title: "Account") {
      AuthStatusBanner(state: authService.authState)

      HStack {
        if !authService.authState.isSignedIn {
          Toggle("Custom Server", isOn: $showCustomServerSettings)
            .controlSize(.small)
            #if os(macOS)
              .toggleStyle(.checkbox)
            #endif

          if showCustomServerSettings {
            TextField(defaultGithubServer, text: $customServer)
              .labelsHidden()
              #if !os(macOS)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
              #endif
          }
        }

        Spacer()

        switch authService.authState {
        case .signedIn, .invalidCredentials, .validating:
          Button("Sign Out", role: .destructive, action: signOut)
        case .signingIn, .awaitingApproval:
          Button("Cancel", role: .cancel, action: cancelSignIn)
            .buttonStyle(.bordered)
        case .signedOut, .failed:
          Button("Sign In with GitHub", action: startSignIn)
            .buttonStyle(.borderedProminent)
        }
      }
    }
    .onAppear {
      if case .awaitingApproval(_, let url) = authService.authState {
        launchService.open(url: url)
      }
    }
    .onChange(of: authService.authState) { _, newState in
      if case .awaitingApproval(_, let url) = newState {
        launchService.open(url: url)
      }
    }
  }

  // MARK: - Helpers

  /// Uses `customServer` if non-empty, otherwise falls back to `defaultGithubServer`.
  private var resolvedServer: String {
    let trimmed = customServer.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? defaultGithubServer : trimmed
  }

  // MARK: - Actions

  private func startSignIn() {
    authService.startSignIn(server: resolvedServer, scopes: ["repo", "read:user"])
  }

  private func cancelSignIn() {
    authService.signOut()
  }

  private func signOut() {
    authService.signOut()
  }
}

// MARK: - AuthStatusBanner

/// Banner view displaying the current auth state with a symbol, title, and detail.
private struct AuthStatusBanner: View {
  let state: GithubAuthState

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
    case .signedOut:
      return "Not Signed In"
    case .signingIn:
      return "Authorizing with GitHub"
    case .awaitingApproval:
      return "Approval Needed"
    case .validating:
      return "Checking Token…"
    case .signedIn(let creds):
      return "Signed In as \(creds.login)"
    case .invalidCredentials:
      return "Signed In (Needs Attention)"
    case .failed:
      return "Sign-In Failed"
    }
  }

  private var statusDetail: Text? {
    switch state {
    case .signedOut:
      return Text("Sign in to enable private repositories and notifications.")
    case .signingIn:
      return Text("Waiting for GitHub authorization to start.")
    case .awaitingApproval(let code, let url):
      return Text("Enter code \(code) [to complete sign-in](\(url)).")
    case .validating(let creds):
      return Text("Checking API access for \(creds.login).")
    case .signedIn(let creds):
      return Text("Token is valid for \(creds.login).")
    case .invalidCredentials(let creds):
      return Text("Stored credentials for \(creds.login) are not currently usable. Sign out and sign in again.")
    case .failed(let message):
      return Text(message)
    }
  }

  private var statusSymbol: String {
    switch state {
    case .signedOut:
      return "person.crop.circle.badge.exclamationmark"
    case .signingIn, .awaitingApproval, .validating:
      return "hourglass.circle.fill"
    case .signedIn:
      return "checkmark.circle.fill"
    case .invalidCredentials:
      return "exclamationmark.triangle.fill"
    case .failed:
      return "xmark.octagon.fill"
    }
  }

  private var statusColor: Color {
    switch state {
    case .signedOut:
      return .secondary
    case .signingIn, .awaitingApproval, .validating:
      return .orange
    case .signedIn:
      return .green
    case .invalidCredentials:
      return .red
    case .failed:
      return .red
    }
  }
}
