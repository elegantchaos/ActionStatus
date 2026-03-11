// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

public struct PreferencesForm: View {
  @Environment(RefreshService.self) var refreshService
  @Environment(SettingsService.self) var settingsService
  @Environment(\.dismiss) private var dismissAction

  public init() {
  }

  public var body: some View {
    List {
      ConnectionPrefsView(token: settingsService.readToken())
        .navigationPrefsStyle()
      NavigationPrefsView()
        .navigationPrefsStyle()
      RefreshPrefsView()
        .navigationPrefsStyle()
      DisplayPrefsView()
        .navigationPrefsStyle()
      DebugPrefsView()
        .navigationPrefsStyle()
    }
    #if os(iOS)
      .listStyle(.insetGrouped)
    #endif
    .onAppear(perform: handleAppear)
    .onDisappear(perform: handleDisappear)
  }

  func handleAppear() {
    refreshService.pauseRefresh()
  }

  func handleDisappear() {
    refreshService.resumeRefresh()
  }


}

struct NavigationPrefsStyleModifier: ViewModifier {
  func body(content: Content) -> some View {
    #if os(macOS)
      content
    #else
      content.listStyle(.insetGrouped)
    #endif
  }
}

extension View {
  func navigationPrefsStyle() -> some View {
    modifier(NavigationPrefsStyleModifier())
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
