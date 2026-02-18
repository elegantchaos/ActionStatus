// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Hardware
import SheetController
import SwiftUI
import SwiftUIExtensions

struct PreferencesButton: View {
  @EnvironmentObject var context: ViewContext
  @Environment(\.horizontalSizeClass) var horizontalSize
  @EnvironmentObject var sheetController: SheetController

  var body: some View {
    Button(action: showPreferences) {
      if (horizontalSize == .compact) || Hardware.Platform.current.base == .tvOS {
        Image(systemName: context.preferencesIcon)
      } else {
        Text("Settings")
      }
    }.accessibility(identifier: "preferencesButton")
  }

  func showPreferences() {
    sheetController.show {
      PreferencesView()
    }
  }
}

struct PreferencesButton_Previews: PreviewProvider {
  static var previews: some View {
    let context = PreviewContext()
    return context.inject(into: PreferencesButton())
  }
}
