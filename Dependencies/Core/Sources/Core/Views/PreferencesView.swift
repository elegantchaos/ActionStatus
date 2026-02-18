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
  @Binding var settings: Settings
  @Binding var token: String

  var body: some View {
    Form {
      Toggle("Use Github API", isOn: $settings.githubAuthentication)

      if settings.githubAuthentication {
        TextField("User", text: $settings.githubUser)
        TextField("Server", text: $settings.githubServer)
        SecureField("Token", text: $token)
      }

      Picker("Refresh Rate", selection: $settings.refreshRate) {
        ForEach(RefreshRate.allCases, id: \.rawValue) { rate in
          Text(rate.labelName).tag(rate)
        }
      }
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
