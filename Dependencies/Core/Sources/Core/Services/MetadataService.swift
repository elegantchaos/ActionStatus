// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Observation
import Runtime

/// Service that exposes runtime metadata and the appropriate model source to the app.
///
/// Wraps the `Runtime` object so that platform-specific decisions (simulator, UI-testing,
/// model source) are made in one place. Services that need this information receive it
/// via dependency injection rather than importing `Runtime` directly.
@Observable
public final class MetadataService {
  /// The underlying `Runtime` instance; excluded from observation to avoid spurious change notifications.
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
    } else if isUITestingBuild {
      return .resource("TestModel")
    } else {
      return .cloud
    }
  }
}
