// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

nonisolated public enum DisplaySize: Int, CaseIterable, Sendable {
  case automatic = 0
  case small = 1
  case medium = 2
  case large = 3
  case huge = 4

  public var normalised: DisplaySize {
    return self == .automatic ? .large : self
  }
}

extension DisplaySize {
  public var labelName: String {
    switch self {
      case .automatic: return "Default (\(normalised.labelName))"
      case .large: return "Large"
      case .huge: return "Huge"
      case .medium: return "Medium"
      case .small: return "Small"
    }
  }
}
