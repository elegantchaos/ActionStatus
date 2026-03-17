// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(iOS)

import Foundation
import UIKit

public extension Engine {
  func showHelp(_ sender: Any) {
    if let url = URL(string: "https://actionstatus.elegantchaos.com/help") {
      UIApplication.shared.open(url)
    }
  }
}

#endif
