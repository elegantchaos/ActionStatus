// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import SwiftUI

@MainActor struct PreviewContext {

  let model: ModelService
  let settings: SettingsService
  
  @MainActor init(isEditing: Bool = true) {
    let status = StatusService()
    model = ModelService([], statusService: status, store: BundleStore(key: "TestModel"))
    settings = SettingsService()
    settings.isEditing = isEditing
  }

  var testRepo: Repo {
    SortMode.name.sort(model.items.values).first!
  }

  func inject<Content>(into view: Content) -> some View where Content: View {
    return
      view
      .environment(model)
      .environment(settings)
  }
}
