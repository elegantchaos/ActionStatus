// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

public extension Scene {
  /// Adds a shared command for importing local repositories.
  func addLocalReposCommand(using engine: Engine) -> some Scene {
    commands {
      CommandGroup(after: .newItem) {
        Button("Add Local Repos", action: engine.addLocalRepos)
          .keyboardShortcut("o", modifiers: .command)
      }
    }
  }
}
