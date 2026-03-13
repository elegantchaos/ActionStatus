// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import SwiftUI

/// Preferences for how repository clicks navigate.
struct NavigationPrefsView: View {
  /// The navigation action used for an unmodified click.
  @AppStorage(.navigationMode) var navigationMode
  /// The navigation action used for the secondary trigger.
  @AppStorage(.secondaryNavigationMode) var secondaryNavigationMode
  /// The navigation action used for the tertiary trigger.
  @AppStorage(.tertiaryNavigationMode) var tertiaryNavigationMode
  
  var body: some View {
    PreferencesSection(title: "Navigation") {
      navigationPicker("repo.navigation.click", selection: $navigationMode)
      #if os(macOS)
        navigationPicker("repo.navigation.commandClick", selection: $secondaryNavigationMode)
        navigationPicker("repo.navigation.optionClick", selection: $tertiaryNavigationMode)
      #endif
    }
  }

  /// Builds a picker for one repository click configuration.
  @ViewBuilder
  func navigationPicker(_ title: LocalizedStringResource, selection: Binding<NavigationMode>) -> some View {
    Picker(title, selection: selection) {
      ForEach(NavigationMode.allCases, id: \.self) { mode in
        Text(mode.label).tag(mode)
      }
    }
  }
}

extension NavigationMode {
  var label: LocalizedStringResource {
    "mode.\(String(describing: self))"
  }
}
