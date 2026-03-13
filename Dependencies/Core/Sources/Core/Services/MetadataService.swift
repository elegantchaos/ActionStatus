// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Observation
import Runtime

/// Service that exposes runtime metadata to the app's shared services.
@Observable
public final class MetadataService {
  @ObservationIgnored public let runtime = Runtime()

  /// Creates a metadata service.
  public init() {
  }

  /// App display name.
  public var appName: String { runtime.bundle.name }

  /// Whether the current build is being used for UI tests.
  public var isUITestingBuild: Bool { runtime.isUITestingBuild }

  /// Whether the app is running on a simulator.
  public var isSimulator: Bool { runtime.isSimulatorBuild }

  /// Stable identifier for the current device.
  public var deviceIdentifier: String? { runtime.deviceIdentifier }

  /// Whether debug UI should be shown.
  public var showDebugUI: Bool { runtime.isDebugBuild && !runtime.isUITestingBuild }

  /// Model source appropriate for the current runtime environment.
  public var modelSource: ModelService.Source {
    if let name = runtime.environment(.testModel) {
      return .resource(name)
    } else if isSimulator || isUITestingBuild {
      return .resource("TestModel")
    } else {
      return .cloud
    }
  }
}
