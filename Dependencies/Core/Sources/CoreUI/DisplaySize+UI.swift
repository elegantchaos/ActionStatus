// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import SwiftUI

extension DisplaySize {
  /// SwiftUI `Font` appropriate for repository cell labels at this display density.
  var font: Font {
    switch normalised {
      case .small: return .body
      case .medium: return .title3
      case .large: return .title2
      case .huge: return .largeTitle
      case .automatic: return .title2
    }
  }

  /// Minimum list row height for this display density; `0` defers to the system default.
  var rowHeight: CGFloat { return 0 }
}
