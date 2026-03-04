// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/02/26.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(iOS)
import Application
  import CoreUI
  import SwiftUI

  @main
  struct MobileApp: App {
    let engine: Engine

    init() {
      engine = Engine()
      engine.standardLoop()
    }
    
    var body: some Scene {
      WindowGroup {
        engine.rootView {
          ProgressView()
        } running: {
          ContentView()
        } error: { error in
          EmptyView()
        }
      }
      .commands {
        CommandGroup(replacing: .appSettings) {
          Button("Preferences…", action: engine.showPreferences)
            .keyboardShortcut(",", modifiers: .command)
        }
      }
      .addLocalReposCommand(using: engine)
    }
  }
#endif
