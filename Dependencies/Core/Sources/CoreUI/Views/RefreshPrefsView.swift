// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import SwiftUI

struct RefreshPrefsView: View {
  @AppStorage(.refreshInterval) var refreshInterval

  var body: some View {
    PreferencesSection(title: "Refresh") {
      Picker("Refresh Rate", selection: $refreshInterval) {
        ForEach(RefreshRate.allCases, id: \.rawValue) { rate in
          Text(rate.labelName).tag(rate)
        }
      }
    }
  }
}
