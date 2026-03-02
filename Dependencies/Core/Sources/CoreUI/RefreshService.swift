// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Keychain

@Observable
@MainActor class RefreshService {
  init(settings: SettingsService, model: Model) {
    self.settingsService = settings
    self.model = model
  }
  
  let settingsService: SettingsService
  let model: Model
  
  public var refreshController: RefreshController? = nil
  
  private var settings: Settings {
    settingsService.settings
  }
  
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
    refreshController?.resume(rate: settings.refreshRate.rate)
  }
  
  func makeRefreshController() -> RefreshController? {
    // disable refreshing for UI testing
    guard !ProcessInfo.processInfo.environment.isTestingUI else { return nil }
    
    if settings.testRefresh {
      return RandomisingRefreshController(model: model)
    }
    
    guard !settings.githubUser.isEmpty else {
      refreshChannel.log("No GitHub account configured. Refresh is disabled until sign-in completes.")
      return nil
    }
    
    do {
      let token = try Keychain.default.password(for: settings.githubUser, on: settings.githubServer)
      guard !token.isEmpty else {
        refreshChannel.log("No GitHub token configured. Refresh is disabled until sign-in completes.")
        return nil
      }
      
      let controller = OctoidRefreshController(model: model, token: token, apiServer: settings.githubServer, refreshInterval: settings.refreshRate.rate)
      refreshChannel.log("Using github refresh controller for \(settings.githubUser)/\(settings.githubServer)")
      return controller
    } catch {
      refreshChannel.log("Couldn't get token: \(error). Refresh is disabled until sign-in completes.")
      return nil
    }
  }
}
