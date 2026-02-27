// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import SwiftUI

struct PreviewContext {

  let model: TestModel
  let state: ViewContext

  @MainActor init(isEditing: Bool = true) {
    model = TestModel()
    state = ViewContext(host: PreviewHost())
    state.settings.isEditing = isEditing
  }

  var testRepo: Repo {
    model.repos(sortedBy: .name).first!
  }

  func inject<Content>(into view: Content) -> some View where Content: View {
    return
      view
      .environment(model)
      .environment(state)
  }
}
