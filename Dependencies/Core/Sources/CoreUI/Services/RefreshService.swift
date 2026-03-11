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

/// Service that manages status refresh scheduling and refresh controller creation.
@Observable
@MainActor
public class RefreshService {
  @ObservationIgnored @AppStorage(.refreshInterval) var refreshInterval
  @ObservationIgnored @AppStorage(.githubUser) var githubUser
  @ObservationIgnored @AppStorage(.githubServer) var githubServer

  /// Supported refresh modes.
  public enum RefreshType {
    case normal
    case random
    case none
  }

  let type: RefreshType
  let modelService: ModelService
  var refreshController: RefreshController? = nil

  /// Creates a refresh service for the supplied model and metadata.
  public init(model: ModelService, metadata: MetadataService, forcedType: RefreshType? = nil) {
    self.modelService = model

    if let forcedType {
      self.type = forcedType
    } else if metadata.runtime.normalized(.testRefresh) == "random" {
      self.type = .random
    } else if metadata.isUITestingBuild {
      self.type = .none
    } else {
      self.type = .normal
    }
  }

  /// Resets any active refresh controller.
  func resetRefresh() {
    refreshServiceChannel.log("Reset")
    refreshController?.pause()
    refreshController = nil
  }

  /// Pauses refresh activity.
  func pauseRefresh() {
    refreshServiceChannel.log("Paused")
    refreshController?.pause()
  }

  /// Resumes refresh activity.
  func resumeRefresh() {
    if refreshController == nil {
      refreshController = makeRefreshController()
    }

    refreshServiceChannel.log("Resumed")
    refreshController?.resume(rate: refreshInterval.rate)
  }

  /// Creates the appropriate refresh controller for the configured mode.
  func makeRefreshController() -> RefreshController? {
    switch type {
      case .normal: return makeGithubRefreshController()
      case .random: return RandomisingRefreshController(model: modelService)
      case .none:
        refreshChannel.log("Refresh is disabled.")
        return nil
    }
  }

  /// Creates a GitHub-backed refresh controller when credentials are available.
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
