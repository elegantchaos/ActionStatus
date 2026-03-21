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
