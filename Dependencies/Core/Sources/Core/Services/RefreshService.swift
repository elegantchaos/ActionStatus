// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Logger
import Observation
import Settings

public let refreshServiceChannel = Channel("Refresh Service")

/// Defines the configuration parameters required for refresh controller creation.
public protocol RefreshConfiguration {
  var githubServer: String { get }
  var refreshInterval: RefreshRate { get }
  var githubToken: String { get }
}

/// Service that manages status refresh scheduling and refresh controller creation.
@Observable
@MainActor
public final class RefreshService {
  /// Supported refresh modes.
  public enum RefreshType {
    case normal
    case random
    case none
  }

  let type: RefreshType
  let modelService: ModelService
  let configuration: RefreshConfiguration
  var refreshController: RefreshController?


  /// Creates a refresh service for the supplied model and metadata.
  public init(
    model: ModelService,
    metadata: MetadataService,
    configuration: RefreshConfiguration,
    forcedType: RefreshType? = nil
  ) {
    self.modelService = model
    self.configuration = configuration

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
  public func resetRefresh() {
    refreshServiceChannel.log("Reset")
    refreshController?.pause()
    refreshController = nil
  }

  /// Pauses refresh activity.
  public func pauseRefresh() {
    refreshServiceChannel.log("Paused")
    refreshController?.pause()
  }

  /// Resumes refresh activity.
  public func resumeRefresh() {
    if refreshController == nil {
      refreshController = makeRefreshController()
    }

    refreshServiceChannel.log("Resumed")
    refreshController?.resume(rate: configuration.refreshInterval.rate)
  }

  /// Creates the appropriate refresh controller for the configured mode.
  func makeRefreshController() -> RefreshController? {
    switch type {
      case .normal:
        return makeGithubRefreshController()
      case .random:
        return RandomisingRefreshController(model: modelService)
      case .none:
        refreshChannel.log("Refresh is disabled.")
        return nil
    }
  }

  /// Creates a GitHub-backed refresh controller when credentials are available.
  public func makeGithubRefreshController() -> RefreshController? {
    let token = configuration.githubToken
    guard !token.isEmpty else {
      githubChannel.log("No GitHub token configured.")
      return nil
    }

    let controller = OctoidRefreshController(
      model: modelService,
      token: token,
      apiServer: configuration.githubServer,
      refreshInterval: configuration.refreshInterval.rate
    )

    return controller
  }
}

extension RefreshService: TypedDebugDescription {
  public var debugLabel: String {
    switch type {
      case .normal:
        return "GitHub"
      case .random:
        return "Random"
      case .none:
        return "None"
    }
  }
}

extension RefreshService {

}
