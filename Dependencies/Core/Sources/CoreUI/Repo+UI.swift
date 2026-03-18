// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/02/26.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import SwiftUI

@MainActor extension Repo {
  /// The SwiftUI color used to tint the status badge for this repo's current state.
  var statusColor: Color {
    switch state {
      case .failing, .partiallyFailing: return .red
      case .passing: return .green
      case .dormant: return .secondary
      default: return .primary
    }
  }
}
