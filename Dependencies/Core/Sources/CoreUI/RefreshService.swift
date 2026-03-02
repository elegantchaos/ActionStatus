// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Keychain
import Settings
import SwiftUI

@Observable
@MainActor class RefreshService {
  @ObservationIgnored @AppStorage(.githubUser) var githubUser
  @ObservationIgnored @AppStorage(.githubServer) var githubServer
  @ObservationIgnored @AppStorage(.testRefresh) var testRefresh
  @ObservationIgnored @AppStorage(.refreshInterval) var refreshInterval

  init(model: Model) {
    self.model = model
  }
  
  let model: Model
  
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
    guard !ProcessInfo.processInfo.environment.isTestingUI else { return nil }
    
    if testRefresh {
      return RandomisingRefreshController(model: model)
    }
    
    guard !githubUser.isEmpty else {
      refreshChannel.log("No GitHub account configured. Refresh is disabled until sign-in completes.")
      return nil
    }
    
    do {
      let token = try Keychain.default.password(for: githubUser, on: githubServer)
      guard !token.isEmpty else {
        refreshChannel.log("No GitHub token configured. Refresh is disabled until sign-in completes.")
        return nil
      }
      
      let controller = OctoidRefreshController(model: model, token: token, apiServer: githubServer, refreshInterval: refreshInterval.rate)
      refreshChannel.log("Using github refresh controller for \(githubUser)/\(githubServer)")
      return controller
    } catch {
      refreshChannel.log("Couldn't get token: \(error). Refresh is disabled until sign-in completes.")
      return nil
    }
  }
}
