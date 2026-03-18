// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/// The display density used to scale repository cell content.
///
/// `.automatic` defers to a platform-appropriate default (`.large`).
/// The raw value is persisted to `UserDefaults` via `AppSettingKey<DisplaySize>`.
nonisolated public enum DisplaySize: Int, CaseIterable, Sendable {
  /// Resolves to the platform default at runtime.
  case automatic = 0
  case small = 1
  case medium = 2
  case large = 3
  case huge = 4

  /// Returns `.large` when `self` is `.automatic`, otherwise returns `self`.
  public var normalised: DisplaySize {
    return self == .automatic ? .large : self
  }
}

extension DisplaySize {
  /// Human-readable label shown in picker UI; `.automatic` includes the resolved default in parentheses.
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
