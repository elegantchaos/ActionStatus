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
class MetadataService {
  @ObservationIgnored let info = AppInfo()
  @ObservationIgnored let device = Device()
}
