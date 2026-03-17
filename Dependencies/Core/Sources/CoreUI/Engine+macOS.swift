// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(macOS)
  import AppKit
  import Core
  import SwiftUI

  public extension Engine {
    func addLocalRepos() {
      let panel = NSOpenPanel()
      panel.canChooseFiles = false
      panel.canChooseDirectories = true
      panel.allowsMultipleSelection = true
      panel.canCreateDirectories = false

      guard panel.runModal() == .OK else { return }
      modelService.addLocalReposIn(panel.urls)
    }

    func applyWindowSettings() {
      let showInDock = UserDefaults.standard.value(forKey: .showInDock)
      let activation: NSApplication.ActivationPolicy = showInDock ? .regular : .accessory
      if NSApp.activationPolicy() != activation {
        NSApp.setActivationPolicy(activation)
      }
    }

  }
#endif
