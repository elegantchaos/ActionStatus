// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import LoggerUI
import SwiftUI
import SwiftUIExtensions

public struct PreferencesView: View {
  @Environment(\.presentationMode) var presentation
  @EnvironmentObject var context: ViewContext
  @EnvironmentObject var model: Model

  @State var settings = Settings()
  @State var owner: String = ""
  @State var token: String = ""
  @State var oldestNewest: Bool = false

  public init() {
  }

  public var body: some View {
    SheetView("ActionStatus Settings", shortTitle: "Settings", cancelAction: handleCancel, doneAction: handleSave) {
      PreferencesForm(
        settings: $settings,
        githubToken: $token,
        defaultOwner: $owner,
        oldestNewest: $oldestNewest
      )
    }
    .onAppear(perform: handleAppear)
  }

  func handleCancel() {
    presentation.wrappedValue.dismiss()
  }

  func handleAppear() {
    Engine.shared.pauseRefresh()
    settings = context.settings
    owner = model.defaultOwner
    token = settings.readToken()
  }

  func handleSave() {
    model.defaultOwner = owner
    let authenticationChanged = settings.authenticationChanged(from: context.settings)
    context.settings = settings
    context.settings.writeToken(token)

    if authenticationChanged {
      Engine.shared.resetRefresh()
    }

    Engine.shared.resumeRefresh()
    presentation.wrappedValue.dismiss()
  }
}

public struct PreferencesForm: View {
  @Binding var settings: Settings
  @Binding var githubToken: String
  @Binding var defaultOwner: String
  @Binding var oldestNewest: Bool
  @AppStorage("selectedSettingsPanel") var selectedPane: PreferenceTabs = .connection

  enum PreferenceTabs: Int, CaseIterable {
    case connection
    case display
    case other
    case debug

    var label: String {
      switch self {
        case .connection: return "Connection"
        case .display: return "Display"
        case .other: return "Other"
        case .debug: return "Debug"
      }
    }
  }

  public var body: some View {
    VStack {
      Picker("Panes", selection: $selectedPane) {
        ForEach(PreferenceTabs.allCases, id: \.self) { kind in
          Text(kind.label).tag(kind)
        }
      }
      .pickerStyle(.segmented)
      .padding(.horizontal)
      .padding(.bottom, 12)

      switch selectedPane {
        case .connection:
          ConnectionPrefsView(settings: $settings, token: $githubToken)
        case .display:
          DisplayPrefsView(settings: $settings)
        case .other:
          OtherPrefsView(owner: $defaultOwner, oldestNewest: $oldestNewest)
        case .debug:
          DebugPrefsView(settings: $settings)
      }
    }
    .padding()
  }
}

struct ConnectionPrefsView: View {
  @EnvironmentObject var context: ViewContext
  @Binding var settings: Settings
  @Binding var token: String
  @State var authState: GithubAuthUIState = .idle
  @State var authTask: Task<Void, Never>? = nil

  var body: some View {
    Form {
      TextField("Server", text: $settings.githubServer)

      if settings.githubUser.isEmpty || token.isEmpty {
        Text("Not signed in")
      } else {
        Text("Signed in as \(settings.githubUser)")
      }

      switch authState {
        case .idle:
          EmptyView()
        case .authenticating:
          Text("Waiting for GitHub authorization...")
        case .awaitingApproval(let code, let url):
          Text("Enter code \(code) at \(url.absoluteString)")
        case .signedIn(let user):
          Text("Signed in as \(user)")
        case .error(let message):
          Text(message)
      }

      if case .awaitingApproval(_, let url) = authState {
        Button("Open GitHub Verification Page") {
          context.host.open(url: url)
        }
      }

      if authTask == nil {
        Button("Sign In with GitHub", action: startSignIn)
      } else {
        Button("Cancel Sign-In", action: cancelSignIn)
      }

      Button("Sign Out", action: signOut)
        .disabled(settings.githubUser.isEmpty && token.isEmpty)

      Picker("Refresh Rate", selection: $settings.refreshRate) {
        ForEach(RefreshRate.allCases, id: \.rawValue) { rate in
          Text(rate.labelName).tag(rate)
        }
      }
    }
    .onDisappear(perform: cancelSignIn)
  }

  func startSignIn() {
    let server = settings.githubServer.trimmingCharacters(in: .whitespacesAndNewlines)
    settings.githubServer = server

    guard let clientID = GithubDeviceAuthenticator.clientID() else {
      authState = .error("Missing Github OAuth client id. Set GithubOAuthClientID in Info.plist build settings.")
      return
    }

    let authenticator = GithubDeviceAuthenticator(apiServer: server, clientID: clientID)
    authState = .authenticating

    authTask = Task {
      do {
        let authorization = try await authenticator.startAuthorization(scopes: [
          "notifications",
          "read:org",
          "read:user",
          "repo",
          "workflow",
        ])

        await MainActor.run {
          authState = .awaitingApproval(authorization.userCode, authorization.verificationURL)
          context.host.open(url: authorization.verificationURL)
        }

        let authenticatedUser = try await authenticator.pollForUser(authorization: authorization)
        await MainActor.run {
          settings.githubUser = authenticatedUser.login
          token = authenticatedUser.token
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
  }

  func signOut() {
    cancelSignIn()
    token = ""
    settings.githubUser = ""
    authState = .idle
  }
}

enum GithubAuthUIState {
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

struct DisplayPrefsView: View {
  @Binding var settings: Settings

  var body: some View {
    Form {
      Picker("Item Size", selection: $settings.displaySize) {
        ForEach(DisplaySize.allCases, id: \.rawValue) { size in
          Text(size.labelName).tag(size)
        }
      }

      Picker("Sort By", selection: $settings.sortMode) {
        ForEach(SortMode.allCases, id: \.rawValue) { mode in
          Text(mode.labelName).tag(mode)
        }
      }

      #if os(macOS)
        Toggle("Show In Menubar", isOn: $settings.showInMenu)
        Toggle("Show In Dock", isOn: $settings.showInDock)
      #endif
    }
  }
}

struct OtherPrefsView: View {
  @Binding var owner: String
  @Binding var oldestNewest: Bool

  var body: some View {
    Form {
      TextField("Default Owner", text: $owner)
      Toggle("Test lowest & highest Swift", isOn: $oldestNewest)
    }
  }
}

struct DebugPrefsView: View {
  @Binding var settings: Settings

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Toggle("Use test refresh controller", isOn: $settings.testRefresh)
      LoggerChannelsHeaderView()
      ScrollView {
        LoggerChannelsStackView()
      }
    }
  }
}
