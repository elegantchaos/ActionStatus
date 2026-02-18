// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import BindingsExtensions
import SheetController
import SwiftUI
import SwiftUIExtensions

public struct ContentView: View {
  @EnvironmentObject var context: ViewContext
  @EnvironmentObject var sheetController: SheetController

  public var body: some View {
    return SheetControllerHost {
      #if targetEnvironment(macCatalyst)
        RootView()
      #else
        return NavigationView {
          RootView()
            .navigationTitle(Application.shared.info.name)
            #if !os(tvOS)
              .navigationBarTitleDisplayMode(.inline)
              .iosToolbar(includeAddButton: context.settings.isEditing)
            #endif
        }
        .navigationViewStyle(StackNavigationViewStyle())
      #endif

    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

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
        //
        //            ToolbarItem(placement: .principal) {
        //                Text(Application.shared.info.name)
        //                    .font(.title)
        //            }

        ToolbarItem(placement: .navigationBarTrailing) {
          ToggleEditingButton()
        }
      }
  }
}
