// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ApplicationExtensions
import Combine
import Hardware
import Keychain
import Logger
import SheetController
import SwiftUI
import SwiftUIExtensions

#if canImport(AppKit)
  import AppKit
#elseif canImport(UIKit)
  import UIKit
#endif

public let settingsChannel = Channel("Settings")
public let monitoringChannel = Channel("Monitoring")
public let refreshControllerChannel = Channel("RefreshController")

open class Engine: BasicApplication, ApplicationHost {
  static var sharedEngine: Engine?

  override init() {
    super.init()
    Engine.sharedEngine = self
  }

  public required init(coder: NSCoder) {
    fatalError()
  }

  override open class var shared: Engine {
    return Engine.sharedEngine!
  }

  #if DEBUG
    let stateKey = "StateDebug"
  #else
    let stateKey = "State"
  #endif

  public lazy var updater: Updater = makeUpdater()
  public lazy var context = makeViewState()
  public var status: RepoState = RepoState()

  public var refreshController: RefreshController? = nil
  #if canImport(UIKit)
    public var rootController: UIViewController?
    public var filePicker: FilePicker?
    open var filePickerClass: FilePicker.Type { return StubFilePicker.self }
  #endif
  public var model = makeModel()
  var observers: [AnyCancellable] = []

  var settings: Settings {
    context.settings
  }

  public let sheetController = SheetController()

  func makeViewState() -> ViewContext {
    return ViewContext(host: self)
  }

  open func makeUpdater() -> Updater {
    return Updater()
  }

  @objc func changed() {
    restoreState()
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

      let controller = OctoidRefreshController(model: model, token: token)
      refreshChannel.log("Using github refresh controller for \(settings.githubUser)/\(settings.githubServer)")
      return controller
    } catch {
      refreshChannel.log("Couldn't get token: \(error). Refresh is disabled until sign-in completes.")
      return nil
    }
  }

  class func makeModel() -> Model {
    let isSimulator = Device.main.system.platform.isSimulator
    let isUITesting = ProcessInfo.processInfo.environment.isTestingUI
    return isSimulator || isUITesting ? TestModel() : Model([])
  }

  public func editNewRepo() {
    sheetController.show {
      EditView(repo: nil)
    }
  }


  open override func setUp(withOptions options: BasicApplication.LaunchOptions, completion: @escaping BasicApplication.SetupCompletion) {
    super.setUp(withOptions: options) { [self] options in
      DispatchQueue.main.async { [self] in
        sheetController.environmentSetter = { view in AnyView(self.applyEnvironment(to: view)) }

        setupDefaultSettings()
        loadSettings()
        restoreState()

        observers.append(
          UserDefaults.standard.onChanged {
            assert(Thread.isMainThread)
            monitoringChannel.log("user defaults changed")
            self.loadSettings()
            self.updateRepoState()
          })

        observers.append(
          model
            .objectWillChange
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .sink {
              assert(Thread.isMainThread)
              monitoringChannel.log("model changed")
              self.saveState()
              self.updateRepoState()
            })

        observers.append(
          context
            .objectWillChange
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .sink { value in
              assert(Thread.isMainThread)
              monitoringChannel.log("view state changed")
              self.saveSettings()
              self.updateRepoState()
            })

        updateRepoState()
        completion(options)
      }
    }
  }

  open func updateRepoState() {
    withAnimation {
      status.update(with: model, context: context)
    }
  }

  open override func tearDown() {
    observers = []
  }

  open func setupDefaultSettings() {
    UserDefaults.standard.register(defaults: [
      .refreshIntervalKey: RefreshRate.automatic.rawValue,
      .displaySizeKey: DisplaySize.automatic.rawValue,
      .sortModeKey: SortMode.state.rawValue,
    ])
  }

  open func loadSettings() {
    settingsChannel.debug("Loading settings")
    pauseRefresh()

    if context.settings.readSettings() == .authenticationChanged {
      // we've changed authentication method, so reset the refresh controller
      resetRefresh()
    }

    resumeRefresh()
  }

  func saveSettings() {
    settingsChannel.debug("Saving settings")
    context.settings.writeSettings()
  }

  public func applyEnvironment<T>(to view: T) -> some View where T: View {
    return
      view
      .environmentObject(context)
      .environmentObject(model)
      .environmentObject(updater)
      .environmentObject(sheetController)
      .environmentObject(status)
  }

  public func saveState() {
    model.save(toDefaultsKey: stateKey)
  }

  func restoreState() {
    model.load(fromDefaultsKey: stateKey)
  }

  public func pauseRefresh() {
    refreshControllerChannel.log("Paused")
    refreshController?.pause()
  }

  public func resumeRefresh() {
    if refreshController == nil {
      refreshController = makeRefreshController()
    }

    refreshControllerChannel.log("Resumed")
    refreshController?.resume(rate: settings.refreshRate.rate)
  }

  func resetRefresh() {
    refreshControllerChannel.log("Reset")
    refreshController?.pause()
    refreshController = nil
  }

  public func open(url: URL) {
    #if canImport(UIKit)
      UIApplication.shared.open(url)
    #elseif canImport(AppKit)
      NSWorkspace.shared.open(url)
    #endif
  }

  open func reveal(url: URL) {
    #if canImport(UIKit)
      UIApplication.shared.open(url)
    #elseif canImport(AppKit)
      NSWorkspace.shared.activateFileViewerSelecting([url])
    #endif
  }

  #if canImport(UIKit)
    public func presentPicker(_ picker: FilePicker) {
      rootController?.present(picker, animated: true) {
      }
      filePicker = picker
    }
  #endif
}

public extension UserDefaults {
  func onChanged(delay: TimeInterval = 1.0, _ action: @escaping () -> Void) -> AnyCancellable {
    NotificationCenter.default
      .publisher(for: UserDefaults.didChangeNotification, object: self)
      .debounce(for: .seconds(delay), scheduler: RunLoop.main)
      .sink { _ in action() }
  }
}
