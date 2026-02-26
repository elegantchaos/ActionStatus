// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/09/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Observation
import SwiftUI

struct FadingFocusButtonStyle: ButtonStyle {
  @Environment(FadingFocusState.self) var focus
  @Environment(\.isFocused) var isFocused: Bool

  func makeBody(configuration: Configuration) -> some View {
    return configuration.label
      .background(isFocused ? Color.gray.opacity(focus.alpha) : Color.clear)
  }
}

@Observable
class FadingFocusState {
  var alpha: Double = 1.0

  func handleFocusChanged() {
    alpha = 1.0
    withAnimation(.easeIn(duration: 20.0)) {
      alpha = 0.0
    }
  }
}
