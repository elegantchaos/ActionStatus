// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Runtime

/// ActionStatus extensions to the Runtime metadata.
extension Runtime {
  /// App display name.
  public var appName: String { bundle.name }

  /// Whether debug UI should be shown.
  public var showDebugUI: Bool { isDebugBuild && !isUITestingBuild }

  /// Model source to use.
  /// Normally we read/write the model to/from the cloud,
  /// but it can be overridden with a canned model read from
  /// a JSON resource, which is useful for testing.
  /// Writes to a resource-based model will work but won't
  /// be persisted past the current run of the app.
  public var modelSource: ModelService.Source {
    if let name = environment(.testModel) {
      return .resource(name)
    } else if isUITestingBuild {
      return .resource("TestModel")
    } else {
      return .cloud
    }
  }

}
