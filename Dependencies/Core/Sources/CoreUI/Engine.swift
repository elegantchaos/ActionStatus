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

public let settingsChannel = Channel("Settings")
public let monitoringChannel = Channel("Monitoring")
public let refreshControllerChannel = Channel("RefreshController")

@Observable
@MainActor public class Engine: AppEngine {
  let metadataService: MetadataService
  var sheetService: SheetService
  var refreshService: RefreshService!

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
        .environment(engine.status)
        .environment(engine.refreshService)
        .environment(engine.sheetService)
        .environment(engine)
    }
  }

  public func initialise() throws {
    modelService.load()
  }

  public func startup() async throws {
    observers.append(
      UserDefaults.standard.onChanged {
        assert(Thread.isMainThread)
        monitoringChannel.log("user defaults changed")
        self.updateRepoState()
      })

    updateRepoState()
  }

  public func retry() async throws {
  }

  public func shouldIgnore(error: any Error) -> Bool {
    false
  }

  public var state: AppState

  @ObservationIgnored @AppStorage(.sortModeKey) public var sortMode


  public init() {
    state = .uninitialised
    self.metadataService = MetadataService()
    self.sheetService = SheetService()
    self.modelService = ModelService(metadata: metadataService)
    self.settingsService = SettingsService()
    self.refreshService = RefreshService(
      model: modelService,
      metadata: metadataService
    )
    self.launchService = LaunchService()
  }

  public var status: RepoState = RepoState()


  #if canImport(UIKit)
    public var rootController: UIViewController?
    public var filePicker: FilePicker?
  #endif
  public let modelService: ModelService
  var observers: [AnyCancellable] = []
  var modelChangeWorkItem: DispatchWorkItem?

  public let settingsService: SettingsService
  public let launchService: LaunchService

  func changed() {
    modelService.load()
  }

  public func editNewRepo() {
    sheetService.presentedSheet = .editRepo(nil)
  }


  open func updateRepoState() {
    let sorted = modelService.repos(sortedBy: sortMode)
    withAnimation {
      status.update(with: sorted)
    }
  }

  open func tearDown() {
    observers = []
    modelChangeWorkItem?.cancel()
    modelChangeWorkItem = nil
  }

  public func modelDidChange() {
    modelChangeWorkItem?.cancel()
    let workItem = DispatchWorkItem { [weak self] in
      guard let self else { return }
      monitoringChannel.log("model changed")
      modelService.save()
      self.updateRepoState()
      self.modelChangeWorkItem = nil
    }

    modelChangeWorkItem = workItem
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
  }

  open func refreshState(completion: @escaping () -> Void = {}) {
    completion()
  }
}

extension CGFloat {
  static let padding: CGFloat = 10
}
