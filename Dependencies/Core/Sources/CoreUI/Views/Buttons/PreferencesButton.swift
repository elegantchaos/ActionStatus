// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Runtime
import SwiftUI

struct PreferencesButton: View {
  @Environment(ViewContext.self) var context

  var body: some View {
    Button(action: showPreferences) {
      if Platform.current.base == .tvOS {
        Image(systemName: context.preferencesIcon)
      } else {
        Text("Settings")
      }
    }.accessibility(identifier: "preferencesButton")
  }

  func showPreferences() {
    context.presentedSheet = .preferences
  }
}

struct PreferencesButton_Previews: PreviewProvider {
  static var previews: some View {
    let context = PreviewContext()
    return context.inject(into: PreferencesButton())
  }
}
