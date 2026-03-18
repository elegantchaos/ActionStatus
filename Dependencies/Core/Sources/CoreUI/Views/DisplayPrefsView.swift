// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import SwiftUI

/// Preferences section for display density, sort order, and platform-specific visibility settings.
struct DisplayPrefsView: View {
  @AppStorage(.showInMenu) var showInMenu
  @AppStorage(.showInDock) var showInDock
  @AppStorage(.sortMode) var sortMode
  @AppStorage(.displaySize) var displaySize
  
  var body: some View {
    PreferencesSection(title: "Display") {
      Picker("Item Size", selection: $displaySize) {
        ForEach(DisplaySize.allCases, id: \.rawValue) { size in
          Text(size.labelName).tag(size)
        }
      }

      Picker("Sort By", selection: $sortMode) {
        ForEach(SortMode.allCases, id: \.rawValue) { mode in
          Text(mode.labelName).tag(mode)
        }
      }

      #if os(macOS)
        Toggle("Show In Menubar", isOn: $showInMenu)
        Toggle("Show In Dock", isOn: $showInDock)
      #endif
    }
  }
}
