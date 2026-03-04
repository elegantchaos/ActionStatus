// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

public struct PreferencesForm: View {
  @Environment(RefreshService.self) var refreshService
  @Environment(SettingsService.self) var settingsService
  @Environment(\.dismiss) private var dismissAction

  @State var githubToken = ""

  public init() {
  }
  
  public var body: some View {
    List {
#if os(macOS)
      ConnectionPrefsView(token: $githubToken)
        .listRowSeparator(.visible, edges: .bottom)
        .listSectionSeparator(.hidden)
      RefreshPrefsView()
        .listRowSeparator(.visible, edges: .bottom)
        .listSectionSeparator(.hidden)
      DisplayPrefsView()
        .listRowSeparator(.visible, edges: .bottom)
        .listSectionSeparator(.hidden)
      DebugPrefsView()
        .listRowSeparator(.visible, edges: .bottom)
        .listSectionSeparator(.hidden)
#else
      ConnectionPrefsView(token: $githubToken)
      RefreshPrefsView()
      DisplayPrefsView()
      DebugPrefsView()
#if os(iOS)
        .listStyle(.insetGrouped)
#endif
#endif
    }
    .onAppear(perform: handleAppear)
    .onDisappear(perform: handleSave)
  }
  
  func handleAppear() {
    refreshService.pauseRefresh()
    githubToken = settingsService.readToken()
  }

  func handleSave() {
    let authenticationChanged = false // settings.authenticationChanged(from: settingsService.settings)
    settingsService.writeToken(githubToken)

    if authenticationChanged {
      refreshService.resetRefresh()
    }
    
    refreshService.resumeRefresh()
  }

  func handleCancel() {
    dismissAction()
  }

}

// MARK: - Previews
//
//#if DEBUG
//  struct PreferencesView_Previews: PreviewProvider {
//    static var previews: some View {
//      Group {
//        #if os(macOS)
//          PreferencesMacWindowPreview()
//            .previewDisplayName("macOS Settings Window")
//        #endif
//        #if os(iOS)
//          PreferencesIOSSheetPreview()
//            .previewDisplayName("iOS Full-Screen Sheet")
//        #endif
//      }
//    }
//  }
//
//  #if os(macOS)
//    private struct PreferencesMacWindowPreview: View {
//      var body: some View {
//        PreviewContext()
//          .inject(into: PreferencesForm())
//          .frame(width: 760, height: 640)
//          .background(Color(nsColor: .windowBackgroundColor))
//          .overlay {
//            RoundedRectangle(cornerRadius: 10)
//              .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
//          }
//          .clipShape(.rect(cornerRadius: 10))
//          .padding()
//      }
//    }
//  #endif
//
//  #if os(iOS)
//    private struct PreferencesIOSSheetPreview: View {
//      var body: some View {
//        PreviewContext()
//          .inject(into: PreferencesIOSPreviewHarness())
//      }
//    }
//
//    private struct PreferencesIOSPreviewHarness: View {
//      @State private var settings = Settings()
//      @State private var token: String = ""
//
//      var body: some View {
//        NavigationStack {
//          PreferencesForm(settings: $settings, githubToken: $token)
//            .navigationTitle("Settings")
//            .navigationBarTitleDisplayMode(.inline)
//        }
//        .onAppear {
//          token = settings.readToken()
//        }
//      }
//    }
//  #endif
//#endif
