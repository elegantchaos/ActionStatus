// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 21/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import SwiftUI

/// Banner view displaying the current auth state with a symbol, title, and detail.
struct AuthStatusBanner: View {
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
      case .invalidCredentials, .failed:
        return .red
    }
  }
}

/// UI model describing when the repo list is visible but refresh is inactive due to auth.
struct AuthMonitoringOverlayModel {
  let title: String
  let message: String
  let symbol: String
  let tint: Color

  init?(state: GithubAuthState) {
    switch state {
      case .signedOut:
        title = "Monitoring Is Inactive"
        message = "Repositories are showing their last known state. Sign in to resume live monitoring."
        symbol = "pause.circle.fill"
        tint = .secondary
      case .validating(let credentials):
        title = "Checking Authentication"
        message = "Repositories are showing their last known state while \(credentials.login)'s token is being checked."
        symbol = "hourglass.circle.fill"
        tint = .orange
      case .invalidCredentials(let credentials):
        title = "Monitoring Is Inactive"
        message = "Stored credentials for \(credentials.login) are no longer valid. Repositories are showing their last known state."
        symbol = "exclamationmark.triangle.fill"
        tint = .red
      case .failed(let detail):
        title = "Monitoring Is Inactive"
        message = "Authentication failed (\(detail)). Repositories are showing their last known state."
        symbol = "xmark.octagon.fill"
        tint = .red
      case .signingIn, .awaitingApproval, .signedIn:
        return nil
    }
  }
}

/// Overlay shown above repo content when auth prevents active monitoring.
struct AuthMonitoringOverlay: View {
  let model: AuthMonitoringOverlayModel

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: model.symbol)
        .font(.title3)
        .foregroundStyle(model.tint)

      VStack(alignment: .leading, spacing: 4) {
        Text(model.title)
          .font(.headline)
        Text(model.message)
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }

      Spacer(minLength: 0)
    }
    .padding(14)
    .background(.ultraThinMaterial)
    .overlay {
      RoundedRectangle(cornerRadius: 14)
        .stroke(model.tint.opacity(0.2), lineWidth: 1)
    }
    .clipShape(.rect(cornerRadius: 14))
    .shadow(color: .black.opacity(0.08), radius: 14, y: 6)
    .allowsHitTesting(false)
    .accessibilityElement(children: .combine)
  }
}

/// Debug view for selecting a simulated auth state in debug builds.
public struct AuthDebugView: View {
  @Environment(\.authService) private var authService

  public init() {
  }

  public var body: some View {
    List {
      PreferencesSection(title: "Authentication") {
        if authService.supportsDebugScenarios {
          Picker("State", selection: selectedScenario) {
            ForEach(AuthDebugScenario.allCases) { scenario in
              Text(scenario.title)
                .tag(scenario)
            }
          }
          .pickerStyle(.menu)

          AuthStatusBanner(state: authService.authState)
        } else {
          Text("Authentication simulation is only available when the app is launched with TEST_AUTH=simulated.")
            .foregroundStyle(.secondary)
        }
      }
    }
    #if os(iOS)
      .listStyle(.insetGrouped)
    #endif
  }

  private var selectedScenario: Binding<AuthDebugScenario> {
    Binding {
      authService.activeDebugScenario ?? AuthDebugScenario(state: authService.authState)
    } set: { newScenario in
      authService.apply(debugScenario: newScenario)
    }
  }
}

#if !VALIDATING
  #Preview("Auth Debug View", traits: .modifier(ActionStatusPreviews.AuthDebug())) {
    AuthDebugView()
      .frame(width: 420, height: 320)
  }
#endif
