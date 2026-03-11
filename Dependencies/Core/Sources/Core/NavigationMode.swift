// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// The available navigation actions for a repository cell.
public enum NavigationMode: String, CaseIterable {
  case edit
  case viewRepo
  case viewWorkflows

  /// Returns the configured mode for the interaction that triggered navigation.
  nonisolated public static func resolve(
    for trigger: NavigationTrigger,
    primaryClick: NavigationMode,
    commandClick: NavigationMode,
    optionClick: NavigationMode
  ) -> NavigationMode {
    switch trigger {
      case .primaryClick:
        primaryClick
      case .commandClick:
        commandClick
      case .optionClick:
        optionClick
    }
  }
}

/// The interaction that initiated repository navigation.
public enum NavigationTrigger: String, CaseIterable, Sendable {
  case primaryClick
  case commandClick
  case optionClick
}
