// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Icons
import Observation
import Runtime
import SwiftUI

/// Main content view for the ActionStatus application.
public struct ContentView: View {
  #if os(iOS)
    @Environment(ActionStatusCommander.self) var commander
    @Environment(SettingsService.self) var settingsService
  #endif

  /// Runtime metadata. Injectable for test purposes.
  let runtime: Runtime

  public init(runtime: Runtime = .shared) {
    self.runtime = runtime
  }

  public var body: some View {
    NavigationStack {
      ReposView()
        .navigationTitle(runtime.appName)
        #if os(iOS)
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            MobileActionsMenu()

            commander.toolbarItem(
              ToggleEditingCommand(settingsService: commander.settingsService),
              placement: .navigationBarTrailing
            )
          }
        #endif
    }
    .sheetHost()
  }
}

/// iOS toolbar menu grouping the primary app-level actions.
struct MobileActionsMenu: ToolbarContent {
  @Environment(ActionStatusCommander.self) var commander

  var body: some ToolbarContent {
    ToolbarItemGroup {

      Menu {
        commander.button(ShowPreferencesSheetCommand())
        commander.button(AddRepoCommand())
        commander.importer(AddLocalReposCommand())
      } label: {
        Label("Settings", icon: .actions)
      }
    }
  }
}

#Preview("Content View", traits: .modifier(ActionStatusPreviews.Content())) {
  ContentView()
    .frame(minWidth: 720, minHeight: 460)
}
