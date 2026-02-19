// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import LoggerUI
import SwiftUI

struct DebugPrefsView: View {
  @Binding var settings: Settings

  var body: some View {
    Section {
      VStack(alignment: .leading, spacing: 12) {
        Toggle("Use test refresh controller", isOn: $settings.testRefresh)
        LoggerChannelsHeaderView()
        ScrollView {
          LoggerChannelsStackView()
        }
      }
    } header: {
      Text("Debug")
        .font(.headline)
        .foregroundStyle(.primary)
    }
  }
}
