// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Application
import Core
import Logger
import Observation
import SwiftUI

#if canImport(UIKit)
  import UIKit
#endif

public let monitoringChannel = Channel("Monitoring")

/// Main ActionStatus runtime engine.
///
/// The engine owns startup state and platform hooks, while `ActionStatusCommander`
/// exposes the reusable command and environment surface used by SwiftUI views.
@Observable
@MainActor
public final class Engine {
  /// The state of the engine.
  public var state: AppState

  /// Startup task tracked by the shared application loop.
  @ObservationIgnored public var startupTask: Task<Void, Never>?

  /// Shared model service.
  public let modelService: ModelService

  /// Shared settings service.
  public let settingsService: SettingsService

  /// Shared launch service.
  public let launchService: LaunchService

  /// Shared metadata service.
  public let metadataService: MetadataService

  /// Shared sheet service.
  public let sheetService: SheetService

  /// Shared refresh service.
  public let refreshService: RefreshService

  /// Shared status service.
  public let statusService: StatusService

  /// Shared commander used by SwiftUI views and menus.
  public let commander: ActionStatusCommander

  #if canImport(UIKit)
    /// Root view controller used for presenting UIKit UI.
    public var rootController: UIViewController?

    /// Retained file picker while it is presented.
    public var filePicker: FilePicker?
  #endif

  /// Performs one-time synchronous initialization.
  public func initialise() throws {
  }

  /// Performs asynchronous startup after initialization.
  public func startup() async throws {
    await modelService.startup()
    refreshService.resumeRefresh()
  }

  /// Creates the live engine and its shared services.
  public init() {
    state = .uninitialised
    startupTask = nil

    let settingsService = SettingsService()
    let metadataService = MetadataService()
    let statusService = StatusService(settingsService: settingsService)
    let sheetService = SheetService()
    let modelService = ModelService(
      statusService: statusService,
      deviceIdentifier: metadataService.deviceIdentifier,
      source: metadataService.modelSource
    )
    let refreshService = RefreshService(
      model: modelService,
      settingsService: settingsService,
      metadata: metadataService
    )
    let launchService = LaunchService()

    self.statusService = statusService
    self.metadataService = metadataService
    self.sheetService = sheetService
    self.modelService = modelService
    self.settingsService = settingsService
    self.refreshService = refreshService
    self.launchService = launchService
    self.commander = ActionStatusCommander(
      modelService: modelService,
      settingsService: settingsService,
      metadataService: metadataService,
      launchService: launchService,
      refreshService: refreshService,
      sheetService: sheetService
    )

    #if os(iOS) || os(macOS)
      commander.setAddLocalReposAction { [weak self] in
        self?.addLocalRepos()
      }
    #endif
  }
}

extension CGFloat {
  static let padding: CGFloat = 10
}

extension Engine: AppEngine {
  public var startupInjector: some ViewModifier {
    ActionStatusEnvironmentInjector(
      commander: commander,
      modelService: modelService,
      metadataService: metadataService,
      settingsService: settingsService,
      launchService: launchService,
      statusService: statusService,
      refreshService: refreshService,
      sheetService: sheetService
    )
  }

  public var runningInjector: some ViewModifier {
    ActionStatusEnvironmentInjector(
      commander: commander,
      modelService: modelService,
      metadataService: metadataService,
      settingsService: settingsService,
      launchService: launchService,
      statusService: statusService,
      refreshService: refreshService,
      sheetService: sheetService
    )
  }

  public func retry() async throws {
  }

  public func shouldIgnore(error: any Error) -> Bool {
    false
  }
}
