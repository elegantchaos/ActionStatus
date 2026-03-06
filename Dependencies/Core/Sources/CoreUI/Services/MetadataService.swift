// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import Runtime

/// Service that views can use to obtain metadata.
/// This is marked as @Observable so that it can be added to the environment,
/// but actually it will not be mutated and should never cause a refresh.
@Observable
public class MetadataService {
  @ObservationIgnored let runtime = Runtime()
  
  var appName: String { runtime.bundle.name }
  
  var isUITestingBuild: Bool { runtime.isUITestingBuild}
  
  var isSimulator: Bool { runtime.isSimulatorBuild }
  
  var deviceIdentifier: String? { runtime.deviceIdentifier }
  
  var modelSource: ModelService.Source {
    if let name = runtime.environment(.testModel) {
      return .resource(name)
    } else if isSimulator || isUITestingBuild {
      return .resource("TestModel")
    } else {
      return .cloud
    }
  }
}
