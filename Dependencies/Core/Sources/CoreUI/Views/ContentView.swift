// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Observation
import SwiftUI

public struct ContentView: View {
  @Environment(ViewContext.self) var context

  public init() {
  }

  public var body: some View {
    @Bindable var context = context

    #if os(macOS)
      RootView()
        .sheet(item: $context.presentedSheet) { sheet in
          sheetView(for: sheet)
        }
    #else
      NavigationStack {
        RootView()
          .navigationTitle(Engine.shared.info.name)
          #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
              ToolbarItem(placement: .navigationBarLeading) {
                if context.settings.isEditing {
                  Button(action: { context.presentedSheet = .editRepo(nil) }) {
                    Text("Add")
                  }
                  .accessibility(identifier: "addButton")
                  .foregroundColor(.black)
                } else {
                  Button(action: { context.presentedSheet = .preferences }) {
                    Text("Settings")
                  }
                  .accessibility(identifier: "preferencesButton")
                }
              }

              ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                  withAnimation {
                    context.settings.isEditing.toggle()
                  }
                }) {
                  Text(context.settings.isEditing ? "Done" : "Edit")
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
