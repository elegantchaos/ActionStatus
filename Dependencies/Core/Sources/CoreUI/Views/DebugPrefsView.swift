// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import LoggerUI
import SwiftUI

struct DebugPrefsView: View {
  @AppStorage(.testRefresh) var testRefresh

  var body: some View {
    Section {
      VStack(alignment: .leading, spacing: 12) {
        Toggle("Use test refresh controller", isOn: $testRefresh)
        LoggerChannelsView()
          .frame(minHeight: 220)
      }
    } header: {
      Text("Debug")
        .font(.headline)
        .foregroundStyle(.primary)
    }
  }
}
