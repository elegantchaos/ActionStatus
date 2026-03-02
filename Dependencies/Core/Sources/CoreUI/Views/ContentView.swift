// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Observation
import SwiftUI

public struct ContentView: View {
  @Environment(Engine.self) var engine
  @Environment(Model.self) var model
  @Environment(SheetService.self) var sheets

  public init() {
  }

  public var body: some View {
    @Bindable var presentedSheet = sheets
    
    #if os(macOS)
    RootView()
      .sheet(item: $presentedSheet.presentedSheet) { sheet in
          sheetView(for: sheet)
        }
    #else
      NavigationStack {
        RootView()
          .navigationTitle(engine.info.name)
          #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
              ToolbarItem(placement: .navigationBarLeading) {
                if settingsService.settings.isEditing {
                  Button(action: { context.presentedSheet = .editRepo(nil) }) {
                    Text("Add")
                  }
                  .accessibility(identifier: "addButton")
                  .foregroundColor(.black)
                } else {
                  Button(action: { context.presentedSheet = .preferences }) {
                    Image(systemName: context.preferencesIcon)
                  }
                  .accessibility(label: Text("Settings"))
                  .accessibility(identifier: "preferencesButton")
                }
              }

              ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                  withAnimation {
                    settingsService.settings.isEditing.toggle()
                  }
                }) {
                  Text(settingsService.settings.isEditing ? "Done" : "Edit")
                }
                .accessibility(identifier: "toggleEditing")
              }
            }
          #endif
      }
      .sheet(item: $context.presentedSheet) { sheet in
        sheetView(for: sheet)
      }
    #endif
  }

  @ViewBuilder
  func sheetView(for sheet: PresentedSheet) -> some View {
    switch sheet {
      case .editRepo(let repo):
        EditView(repo: repo)
      case .preferences:
        PreferencesView()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
