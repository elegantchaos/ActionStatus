// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Observation
import SwiftUI

/// Main content view for the ActionStatus application.
public struct ContentView: View {
  @Environment(MetadataService.self) var metadataService

  #if os(iOS)
    @Environment(ActionStatusCommander.self) var commander
    @Environment(SettingsService.self) var settingsService
  #endif

  public init() {
  }

  public var body: some View {
    NavigationStack {
      ReposView()
        .navigationTitle(metadataService.appName)
        #if os(iOS)
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
              if settingsService.isEditing {
                commander.button(ShowEditSheetCommand())
              } else {
                commander.button(ShowPreferencesSheetCommand())
              }
            }

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
