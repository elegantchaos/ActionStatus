// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct PreviewContext {

  let model: TestModel
  let state: ViewContext

  init(isEditing: Bool = true) {
    model = TestModel()
    state = ViewContext(host: PreviewHost())
    state.settings.isEditing = isEditing
  }

  var testRepo: Repo {
    model.repos.first!
  }

  func inject<Content>(into view: Content) -> some View where Content: View {
    return
      view
      .environmentObject(model)
      .environmentObject(state)
  }
}
