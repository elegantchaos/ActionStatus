// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/09/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Observation
import SwiftUI

/// Manages the animated alpha of the tvOS focus highlight.
///
/// Drives `FadingFocusButtonStyle`; the highlight fades out over 20 seconds
/// so it does not obscure the UI after the user stops navigating.
@Observable
final class FadingFocusState {
  /// Current opacity of the focus highlight (0–1).
  var alpha: Double = 1.0

  /// Resets alpha to 1 and starts a 20-second ease-in fade.
  func handleFocusChanged() {
    alpha = 1.0
    withAnimation(.easeIn(duration: 20.0)) {
      alpha = 0.0
    }
  }
}
