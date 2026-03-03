// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Keychain
import Runtime
import Settings
import SwiftUI

@Observable
@MainActor class RefreshService {
  @ObservationIgnored @AppStorage(.testRefresh) var testRefresh
  @ObservationIgnored @AppStorage(.refreshInterval) var refreshInterval

  init(model: ModelService, metadata: MetadataService) {
    self.modelService = model
    self.metadata = metadata
  }

  let modelService: ModelService
  let metadata: MetadataService

  public var refreshController: RefreshController? = nil

  func resetRefresh() {
    refreshControllerChannel.log("Reset")
    refreshController?.pause()
    refreshController = nil
  }

  func pauseRefresh() {
    refreshControllerChannel.log("Paused")
    refreshController?.pause()
  }

  func resumeRefresh() {
    if refreshController == nil {
      refreshController = makeRefreshController()
    }

    refreshControllerChannel.log("Resumed")
    refreshController?.resume(rate: refreshInterval.rate)
  }

  func makeRefreshController() -> RefreshController? {
    // disable refreshing for UI testing
    guard !metadata.info.isUITestingBuild else { return nil }

    if testRefresh {
      return modelService.makeRandomisingRefreshController()
    } else {
      if let refresh = modelService.makeRefreshController() {
        return refresh
      } else {
        refreshChannel.log("Refresh is disabled until sign-in completes.")
        return nil
      }
    }
  }
}
