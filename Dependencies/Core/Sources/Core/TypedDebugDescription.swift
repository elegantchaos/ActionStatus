// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Protocol supplying a debugDescription with some standard formatting.
public nonisolated protocol TypedDebugDescription: CustomDebugStringConvertible {
  var debugLabel: String { get }
}

/// Display modes for typed debug descriptions.
nonisolated enum TypedDebugMode {
  /// Show type and label.
  case normal
  
  /// Just show label.
  case simple
}

/// Global mode for typed debug descriptions.
nonisolated let typedDebugMode = TypedDebugMode.normal

/// Implementation of debugDescription which uses some standard
/// formatting to wrap a custom label.
extension TypedDebugDescription {
  nonisolated public var debugDescription: String {
    switch typedDebugMode {
      case .normal:
        "«\(type(of: self)): \(debugLabel)»"
      case .simple:
        "«\(debugLabel)»"
    }
  }
}

nonisolated extension Optional: TypedDebugDescription where Wrapped: TypedDebugDescription {
  public var debugLabel: String {
    switch self {
      case .none: return "<nil>"
      case .some(let value): return value.debugLabel
    }
  }
}
