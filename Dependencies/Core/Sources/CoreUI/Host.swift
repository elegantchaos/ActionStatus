// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 21/07/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Runtime

@MainActor public protocol ApplicationHost {
  func open(url: URL)
  func reveal(url: URL)
  func modelDidChange()
  func settingsDidChange()
}

extension ApplicationHost {
  func open(url: URL) {
  }

  func reveal(url: URL) {

  }
}
