// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Application
import Combine
import Core
import Keychain
import Logger
import Observation
import Runtime
import SwiftUI

#if canImport(UIKit)
  import UIKit
#endif

public let monitoringChannel = Channel("Monitoring")

@Observable
@MainActor public class Engine {
  /// The state of the engine.
  public var state: AppState

  public let modelService: ModelService
  public let settingsService: SettingsService
  public let launchService: LaunchService
  public let metadataService: MetadataService
  public let sheetService: SheetService
  public let refreshService: RefreshService
  public let statusService: StatusService

  #if canImport(UIKit)
    public var rootController: UIViewController?
    public var filePicker: FilePicker?
  #endif

  public func initialise() throws {
  }

  public func startup() async throws {
    await modelService.startup()
    refreshService.resumeRefresh()
  }

  public init() {
    state = .uninitialised

    let ms = MetadataService()

    self.statusService = StatusService()
    self.metadataService = ms
    self.sheetService = SheetService()
    self.modelService = ModelService(
      statusService: statusService,
      source: ms.modelSource
    )
    self.settingsService = SettingsService()
    self.refreshService = RefreshService(model: modelService, metadata: ms)
    self.launchService = LaunchService()
  }

  public func editNewRepo() {
    sheetService.presentedSheet = .editRepo(nil)
  }
}

extension CGFloat {
  static let padding: CGFloat = 10
}

extension Engine: AppEngine {
  public var startupInjector: some ViewModifier { EnvironmentInjector(engine: self) }
  public var runningInjector: some ViewModifier { EnvironmentInjector(engine: self) }

  struct EnvironmentInjector: ViewModifier {
    let engine: Engine

    func body(content: Content) -> some View {
      content
        .environment(engine.modelService)
        .environment(engine.metadataService)
        .environment(engine.settingsService)
        .environment(engine.launchService)
        .environment(engine.statusService)
        .environment(engine.refreshService)
        .environment(engine.sheetService)
        .environment(engine)
    }
  }

  public func retry() async throws {
  }

  public func shouldIgnore(error: any Error) -> Bool {
    false
  }
}
