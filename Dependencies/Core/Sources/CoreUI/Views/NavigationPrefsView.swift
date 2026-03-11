// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import SwiftUI

struct NavigationPrefsView: View {
  @AppStorage(.navigationMode) var navigationMode
  
  var body: some View {
    PreferencesSection(title: "Navigation") {
      Picker("repo.navigation.picker", selection: $navigationMode) {
        ForEach(NavigationMode.allCases, id: \.self) { mode in
          Text(mode.label).tag(mode)
        }
      }
    }
  }
}

extension NavigationMode {
  var label: LocalizedStringResource {
    "mode.\(String(describing: self))"
  }
}
