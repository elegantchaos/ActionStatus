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
      List {
        ConnectionPrefsView(settings: $settings, token: $githubToken)
        RefreshPrefsView(settings: $settings)
        DisplayPrefsView(settings: $settings)
        DebugPrefsView(settings: $settings)
      }
      #if os(iOS)
        .listStyle(.insetGrouped)
      #endif
    #endif
  }
}

// MARK: - Previews

#if DEBUG
  struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
      Group {
        #if os(macOS)
          PreferencesMacWindowPreview()
            .previewDisplayName("macOS Settings Window")
        #endif
        #if os(iOS)
          PreferencesIOSSheetPreview()
            .previewDisplayName("iOS Full-Screen Sheet")
        #endif
      }
    }
  }

  #if os(macOS)
    private struct PreferencesMacWindowPreview: View {
      var body: some View {
        PreviewContext()
          .inject(into: AppSettingsView())
          .frame(width: 760, height: 640)
          .background(Color(nsColor: .windowBackgroundColor))
          .overlay {
            RoundedRectangle(cornerRadius: 10)
              .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
          }
          .clipShape(.rect(cornerRadius: 10))
          .padding()
      }
    }
  #endif

  #if os(iOS)
    private struct PreferencesIOSSheetPreview: View {
      var body: some View {
        PreferencesIOSSheetHost()
      }
    }

    private struct PreferencesIOSSheetHost: View {
      @State private var showSettings = true

      var body: some View {
        ZStack {
          Color(uiColor: .systemGroupedBackground)
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showSettings) {
          PreviewContext()
            .inject(into: PreferencesView())
        }
      }
    }
  #endif
#endif
