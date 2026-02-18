// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 21/07/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Bundles
import Foundation

public protocol ApplicationHost {
  var info: BundleInfo { get }
  func saveState()
  func open(url: URL)
  func reveal(url: URL)
  func pauseRefresh()
  func resumeRefresh()
}

extension ApplicationHost {
  var info: BundleInfo {
    BundleInfo(for: Bundle.main)
  }

  func saveState() {

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
