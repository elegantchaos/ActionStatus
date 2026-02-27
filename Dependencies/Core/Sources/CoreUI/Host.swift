// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 21/07/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Runtime

public protocol ApplicationHost {
  var info: AppInfo { get }
  func open(url: URL)
  func reveal(url: URL)
  func pauseRefresh()
  func resumeRefresh()
}

extension ApplicationHost {
  var info: AppInfo {
    Bundle.main.runtimeInfo
  }

  func open(url: URL) {
  }

  func reveal(url: URL) {

  }

  func pauseRefresh() {

  }

  func resumeRefresh() {

  }
}
