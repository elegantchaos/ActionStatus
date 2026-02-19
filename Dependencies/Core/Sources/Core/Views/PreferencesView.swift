// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import SwiftUIExtensions

public struct AppSettingsView: View {
  @EnvironmentObject var context: ViewContext
  @EnvironmentObject var model: Model

  @State var settings = Settings()
  @State var token: String = ""

  public init() {
  }

  public var body: some View {
    PreferencesForm(
      settings: $settings,
      githubToken: $token
    )
    #if os(macOS)
      .frame(maxWidth: .infinity, alignment: .center)
      .padding(.horizontal, 12)
      .padding(.vertical, 16)
    #endif
    .onAppear(perform: handleAppear)
    .onDisappear(perform: handleSave)
  }

  func handleAppear() {
    settings = context.settings
    token = settings.readToken()
  }

  func handleSave() {
    let authenticationChanged = settings.authenticationChanged(from: context.settings)
    context.settings = settings
    context.settings.writeToken(token)

    if authenticationChanged {
      Engine.shared.resetRefresh()
    }
  }
}

public struct PreferencesView: View {
  @Environment(\.presentationMode) var presentation
  @EnvironmentObject var context: ViewContext

  @State var settings = Settings()
  @State var token: String = ""

  public init() {
  }

  public var body: some View {
    SheetView("ActionStatus Settings", shortTitle: "Settings", cancelAction: handleCancel, doneAction: handleSave) {
      PreferencesForm(
        settings: $settings,
        githubToken: $token
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
    token = settings.readToken()
  }

  func handleSave() {
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
  #if !os(macOS)
    @AppStorage("selectedSettingsPanel") var selectedPane: PreferenceTabs = .connection

    enum PreferenceTabs: Int, CaseIterable {
      case connection
      case refresh
      case display
      case debug

      var label: String {
        switch self {
          case .connection: return "Connection"
          case .refresh: return "Refresh"
          case .display: return "Display"
          case .debug: return "Debug"
        }
      }
    }
  #endif

  public var body: some View {
    #if os(macOS)
      List {
        ConnectionPrefsView(settings: $settings, token: $githubToken)
          .listRowSeparator(.visible, edges: .bottom)
          .listSectionSeparator(.hidden)
        RefreshPrefsView(settings: $settings)
          .listRowSeparator(.visible, edges: .bottom)
          .listSectionSeparator(.hidden)
        DisplayPrefsView(settings: $settings)
          .listRowSeparator(.visible, edges: .bottom)
          .listSectionSeparator(.hidden)
        DebugPrefsView(settings: $settings)
          .listRowSeparator(.visible, edges: .bottom)
          .listSectionSeparator(.hidden)
      }
    #else
      VStack {
        Picker("Panes", selection: $selectedPane) {
          ForEach(PreferenceTabs.allCases, id: \.self) { kind in
            Text(kind.label).tag(kind)
          }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.bottom, 12)

        Form {
          switch selectedPane {
            case .connection:
              ConnectionPrefsView(settings: $settings, token: $githubToken)
            case .refresh:
              RefreshPrefsView(settings: $settings)
            case .display:
              DisplayPrefsView(settings: $settings)
            case .debug:
              DebugPrefsView(settings: $settings)
          }
        }
      }
      .padding()
    #endif
  }
}
