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
            .iosToolbar(includeAddButton: context.settings.isEditing)
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

#if os(iOS)
  extension View {
    func iosToolbar(includeAddButton: Bool) -> some View {
      self
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            if includeAddButton {
              AddButton()
            } else {
              PreferencesButton()
            }
          }

          ToolbarItem(placement: .navigationBarTrailing) {
            ToggleEditingButton()
          }
        }
    }
  }
#endif
