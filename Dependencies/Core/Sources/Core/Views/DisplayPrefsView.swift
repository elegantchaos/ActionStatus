// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct DisplayPrefsView: View {
  @Binding var settings: Settings

  var body: some View {
    Section {
      VStack(alignment: .leading, spacing: 12) {
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
    } header: {
      Text("Display")
        .font(.headline)
        .foregroundStyle(.primary)
    }
  }
}
