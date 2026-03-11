// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Shared section styling used by preferences panels.
struct PreferencesSection<Content: View>: View {
  /// Title displayed in the section header.
  let title: String

  /// Section body content.
  @ViewBuilder let content: () -> Content

  var body: some View {
    Section {
      VStack(alignment: .leading, spacing: 12) {
        content()
      }
    } header: {
      Text(title)
        .font(.headline)
        .foregroundStyle(.primary)
    }
  }
}
