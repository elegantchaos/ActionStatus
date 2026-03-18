// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/09/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Button style that fades the focus highlight out over time on tvOS.
///
/// Reads `FadingFocusState` from the environment and dims the grey focus
/// background according to its current alpha, so the highlight disappears
/// naturally after the user stops navigating.
struct FadingFocusButtonStyle: ButtonStyle {
  @Environment(FadingFocusState.self) var focus
  @Environment(\.isFocused) var isFocused: Bool

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .background(isFocused ? Color.gray.opacity(focus.alpha) : Color.clear)
  }
}
