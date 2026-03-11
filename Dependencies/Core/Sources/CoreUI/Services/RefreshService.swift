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
  @ObservationIgnored @AppStorage(.refreshInterval) var refreshInterval
  @ObservationIgnored @AppStorage(.githubUser) var githubUser
  @ObservationIgnored @AppStorage(.githubServer) var githubServer

  let type: RefreshType
  let modelService: ModelService
  var refreshController: RefreshController? = nil

  init(model: ModelService, metadata: MetadataService) {
    self.modelService = model

    if metadata.runtime.normalized(.testRefresh) == "random" {
      self.type = .random
    } else if metadata.isUITestingBuild {
      self.type = .none
    } else {
      self.type = .normal
    }
  }

  enum RefreshType {
    case normal
    case random
    case none
  }


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
    switch type {
      case .normal: return makeGithubRefreshController()
      case .random: return RandomisingRefreshController(model: modelService)
      case .none:
        refreshChannel.log("Refresh is disabled.")
        return nil
    }
  }

  public func makeGithubRefreshController() -> RefreshController? {
    do {
      guard !githubUser.isEmpty else {
        githubChannel.log("No GitHub account configured.")
        return nil
      }

      let token = try Keychain.default.password(for: githubUser, on: githubServer)
      guard !token.isEmpty else {
        githubChannel.log("No GitHub token configured.")
        return nil
      }

      let controller = OctoidRefreshController(
        model: modelService,
        token: token,
        apiServer: githubServer,
        refreshInterval: refreshInterval.rate
      )

      githubChannel.log("Using github refresh controller for \(githubUser)/\(githubServer)")
      return controller
    } catch {
      githubChannel.log("Couldn't get token: \(error).")
      return nil
    }
  }

}
