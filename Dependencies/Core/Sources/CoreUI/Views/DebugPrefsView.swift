// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import LoggerUI
import Runtime
import SwiftUI

/// Displays debug build information and the logger channel control panel.
struct DebugPrefsView: View {
  @Environment(RefreshService.self) var refreshService
  @Environment(ModelService.self) var modelService

  /// Runtime metadata. Injectable for test purposes.
  let runtime: Runtime

  init(runtime: Runtime = .shared) {
    self.runtime = runtime
  }

  var body: some View {
    let source = runtime.modelSource
    return PreferencesSection(title: "Debug") {
      Text("Source: \(String(describing: source))")
      Text(modelService.debugDescription)
      Text(refreshService.debugDescription)
      LoggerChannelsView()
        .frame(minHeight: 220)
    }
  }
}
