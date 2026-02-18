// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/02/26.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(macOS)
  import Core
  import SwiftUI

  @main
  struct MacApp: App {
    @NSApplicationDelegateAdaptor(MacApplication.self) private var application

    var body: some Scene {
      WindowGroup {
        Engine.shared.applyEnvironment(to: ContentView())
      }
      .commands {
        CommandGroup(replacing: .appSettings) {
          Button("Preferences…", action: application.showPreferences)
            .keyboardShortcut(",", modifiers: .command)
        }

        CommandGroup(after: .newItem) {
          Button("Add Local Repos", action: application.addLocalRepos)
            .keyboardShortcut("o", modifiers: .command)
        }
      }
    }
  }
#endif
