// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Polling intervals available to the user.
///
/// The raw value doubles as the interval in seconds, except for `.automatic` which
/// resolves to `.minute` at runtime. The enum is `RawRepresentable` so it can be
/// stored in `UserDefaults` via `AppSettingKey<RefreshRate>`.
public enum RefreshRate: Int, CaseIterable, Equatable, Sendable {
  /// Resolves to the platform default (`.minute`) at runtime.
  case automatic = 0
  case quick = 30
  case minute = 60
  case fiveMinute = 300
  case tenMinute = 600

  /// Returns `.minute` when `self` is `.automatic`, otherwise returns `self`.
  public var normalised: RefreshRate {
    self == .automatic ? RefreshRate.minute : self
  }

  /// The refresh interval in seconds, resolved through `normalised`.
  public var rate: TimeInterval {
    return TimeInterval(self.normalised.rawValue)
  }
}

extension RefreshRate {
  /// Human-readable label shown in picker UI; `.automatic` includes the resolved default in parentheses.
  public var labelName: String {
    if self == .automatic {
      return "Default (\(normalised.labelName))"
    } else if rawValue < 60 {
      return "\(rawValue) seconds"
    } else {
      return "\(rawValue / 60) minutes"
    }
  }
}
