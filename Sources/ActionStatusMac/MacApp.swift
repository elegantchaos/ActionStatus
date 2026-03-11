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
      Window(engine.metadataService.appName, id: "repos") {
        engine.rootView {
          ContentView()
        }
        .windowDismissBehavior(.disabled)
      }
      .windowStyle(.hiddenTitleBar)
      .windowManagerRole(.principal)
      .windowResizability(.contentMinSize)
//      .windowToolbarStyle(.unified)

      Settings {
        PreferencesForm()
          .modifier(engine.runningInjector)
          .frame(maxWidth: .infinity, alignment: .center)
          .padding(.horizontal, 12)
          .padding(.vertical, 16)
      }
      .defaultSize(width: 720, height: 620)
      .windowResizability(.automatic)
      .commands {
        CommandGroup(after: .newItem) {
          engine.button(AddLocalReposCommand())
        }
        CommandGroup(after: .textEditing) {
          engine.button(ToggleEditingCommand(settingsService: engine.settingsService))
        }
      }

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
