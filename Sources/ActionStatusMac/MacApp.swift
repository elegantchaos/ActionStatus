// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/02/26.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(macOS)
  import Core
  import CoreUI
  import SwiftUI
  import Settings
  import Application

  @main
  struct MacApp: App {
    @NSApplicationDelegateAdaptor(MacDelegate.self) private var delegate

    @AppStorage(.showInMenu) private var showInMenu

    let engine: Engine

    init() {
      engine = Engine()
      engine.standardLoop()
    }


    var body: some Scene {
      WindowGroup {
        engine.rootView {
          ContentView()
        }
      }

      Settings {
        PreferencesForm()
          .modifier(engine.runningInjector)
          .frame(maxWidth: .infinity, alignment: .center)
          .padding(.horizontal, 12)
          .padding(.vertical, 16)
      }
      .defaultSize(width: 720, height: 620)
      .windowResizability(.automatic)
      .addLocalReposCommand(using: engine)

      MenuBarExtra(isInserted: $showInMenu) {
          StatusMenuContent()
          .modifier(engine.startupInjector)
      } label: {
          StatusMenuLabel()
          .modifier(engine.startupInjector)
      }
    }
  }
#endif
