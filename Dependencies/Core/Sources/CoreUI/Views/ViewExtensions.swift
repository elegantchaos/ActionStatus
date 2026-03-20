// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Applies `.title2` font to the status icon and label pair.
internal struct StatusStyleModifier: ViewModifier {
  /// Returns the modified content.
  func body(content: Content) -> some View {
    content
      .font(.title2)
  }
}

internal extension View {
  /// Applies the standard status icon font size.
  func statusStyle() -> some View {
    self
      .modifier(StatusStyleModifier())
  }
}
