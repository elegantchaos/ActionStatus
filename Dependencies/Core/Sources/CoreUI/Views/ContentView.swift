// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Observation
import SwiftUI

public struct ContentView: View {
  @Environment(MetadataService.self) var metadataService

#if os(iOS)
    @Environment(Engine.self) var engine
    @Environment(SettingsService.self) var settingsService
  #endif

  public init() {
  }

  public var body: some View {
    NavigationStack {
      RootView()
        .navigationTitle(metadataService.appName)
        #if os(iOS)
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
              if settingsService.isEditing {
                engine.button(ShowEditSheetCommand())
              } else {
                engine.button(ShowPreferencesSheetCommand())
              }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
              Button(action: {
                withAnimation {
                  _ = settingsService.toggleEditing()
                }
              }) {
                Text(settingsService.isEditing ? "Done" : "Edit")
              }
              .accessibility(identifier: "toggleEditing")
            }
          }
        #endif
    }
    .sheetHost()
  }

}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
