// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Observation
import SwiftUI

@Observable
open class Updater {
  public var progress: Double = 0
  public var status: String = ""
  public var hasUpdate: Bool = false

  public init() {
  }

  open func installUpdate() {}
  open func skipUpdate() {}
  open func ignoreUpdate() {}
}
