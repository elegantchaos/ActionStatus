// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Runtime

public extension EnvironmentKey {
  
  /// Variable for injecting a test model.
  static let testModel = EnvironmentKey("TEST_MODEL")

  /// Variable for configuring a test refresh controller.
  static let testRefresh = EnvironmentKey("TEST_REFRESH")

}
