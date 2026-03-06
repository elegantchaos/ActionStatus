// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Keychain
import Logger
import Runtime
import Settings
import SwiftUI

public let refreshServiceChannel = Channel("Refresh Service")

@Observable
@MainActor public class RefreshService {
  @ObservationIgnored @AppStorage(.testRefresh) var testRefresh
  @ObservationIgnored @AppStorage(.refreshInterval) var refreshInterval
  @ObservationIgnored @AppStorage(.githubUser) var githubUser
  @ObservationIgnored @AppStorage(.githubServer) var githubServer

  init(model: ModelService, metadata: MetadataService) {
    self.modelService = model
    self.metadata = metadata
  }

  let modelService: ModelService
  let metadata: MetadataService

  public var refreshController: RefreshController? = nil

  func resetRefresh() {
    refreshServiceChannel.log("Reset")
    refreshController?.pause()
    refreshController = nil
  }

  func pauseRefresh() {
    refreshServiceChannel.log("Paused")
    refreshController?.pause()
  }

  func resumeRefresh() {
    if refreshController == nil {
      refreshController = makeRefreshController()
    }

    refreshServiceChannel.log("Resumed")
    refreshController?.resume(rate: refreshInterval.rate)
  }

  func makeRefreshController() -> RefreshController? {
    // disable refreshing for UI testing
    guard !metadata.isUITestingBuild else { return nil }

    if testRefresh {
      return RandomisingRefreshController(model: modelService)
    } else {
      if let refresh = makeGithubRefreshController() {
        return refresh
      } else {
        refreshChannel.log("Refresh is disabled until sign-in completes.")
        return nil
      }
    }
  }

  public func makeGithubRefreshController() -> RefreshController? {
    guard !githubUser.isEmpty else {
      githubChannel.log("No GitHub account configured.")
      return nil
    }

    do {
      let token = try Keychain.default.password(for: githubUser, on: githubServer)
      guard !token.isEmpty else {
        githubChannel.log("No GitHub token configured.")
        return nil
      }

      let controller = OctoidRefreshController(model: modelService, token: token, apiServer: githubServer, refreshInterval: refreshInterval.rate)
      githubChannel.log("Using github refresh controller for \(githubUser)/\(githubServer)")
      return controller
    } catch {
      githubChannel.log("Couldn't get token: \(error).")
      return nil
    }
  }

}
