// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import SwiftUI

@MainActor struct PreviewContext {

  let model: ModelService
  let status: StatusService
  let metadata: MetadataService
  let settings: SettingsService
  
  @MainActor init(isEditing: Bool = true) {
    status = StatusService()
    metadata = MetadataService()
    model = ModelService(
  [],
  statusService: status,
  deviceIdentifier: metadata.deviceIdentifier,
  store: BundleStore(key: "TestModel")
    )
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
      .environment(status)
      .environment(settings)
      .environment(metadata)
  }
}
