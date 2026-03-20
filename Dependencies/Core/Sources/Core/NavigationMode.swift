// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// The navigation action performed when a repository cell is tapped.
public enum NavigationMode: String, CaseIterable {
  /// Open the edit sheet for the repository.
  case edit
  /// Open the repository's main page on GitHub.
  case viewRepo
  /// Open the repository's Actions (workflow) page on GitHub.
  case viewWorkflows
}
