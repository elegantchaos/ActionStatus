// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Observation
import SwiftUI

public struct ContentView: View {
  @Environment(Engine.self) var engine
  @Environment(SheetService.self) var sheetService
  @Environment(SettingsService.self) var settingsService
  @Environment(MetadataService.self) var metadataService
  
  public init() {
  }

  public var body: some View {
    #if os(macOS)
    RootView()
      .sheetHost()
    #else
      NavigationStack {
        RootView()
          .navigationTitle(metadataService.appName)
          #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
              ToolbarItem(placement: .navigationBarLeading) {
                if settingsService.isEditing {
                  engine.button(ShowAddSheetCommand())
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
    #endif
  }

}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
