// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import LoggerUI
import SwiftUI

/// Displays debug build information and the logger channel control panel.
struct DebugPrefsView: View {
  @Environment(MetadataService.self) var metadataService
  @Environment(RefreshService.self) var refreshService
  @Environment(ModelService.self) var modelService

  var body: some View {
    let source = metadataService.modelSource
    return PreferencesSection(title: "Debug") {
      Text("Source: \(String(describing: source))")
      Text(modelService.debugDescription)
      Text(refreshService.debugDescription)
      LoggerChannelsView()
        .frame(minHeight: 220)
    }
  }
}
