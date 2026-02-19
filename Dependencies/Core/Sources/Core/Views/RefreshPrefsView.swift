// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct RefreshPrefsView: View {
  @Binding var settings: Settings

  var body: some View {
    Section {
      VStack(alignment: .leading, spacing: 12) {
        Picker("Refresh Rate", selection: $settings.refreshRate) {
          ForEach(RefreshRate.allCases, id: \.rawValue) { rate in
            Text(rate.labelName).tag(rate)
          }
        }
      }
    } header: {
      Text("Refresh")
        .font(.headline)
        .foregroundStyle(.primary)
    }
  }
}
