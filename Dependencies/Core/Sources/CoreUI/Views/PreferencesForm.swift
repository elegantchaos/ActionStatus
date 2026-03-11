// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Main preferences form for ActionStatus settings.
public struct PreferencesForm: View {
  @Environment(RefreshService.self) var refreshService
  @Environment(SettingsService.self) var settingsService
  @Environment(\.dismiss) private var dismissAction

  public init() {
  }

  public var body: some View {
    List {
      ConnectionPrefsView(token: settingsService.readToken())
      NavigationPrefsView()
      RefreshPrefsView()
      DisplayPrefsView()
      DebugPrefsView()
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
    #if os(iOS)
      content.listStyle(.insetGrouped)
    #else
      content
    #endif
  }
}

extension View {
  /// Applies platform-appropriate styling for navigation-related preferences sections.
  func navigationPrefsStyle() -> some View {
    modifier(NavigationPrefsStyleModifier())
  }
}
