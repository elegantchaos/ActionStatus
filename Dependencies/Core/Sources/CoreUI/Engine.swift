// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Combine
import Core
import Keychain
import Logger
import Observation
import Runtime
import SwiftUI

#if canImport(AppKit)
  import AppKit
#elseif canImport(UIKit)
  import UIKit
#endif

public let settingsChannel = Channel("Settings")
public let monitoringChannel = Channel("Monitoring")
public let refreshControllerChannel = Channel("RefreshController")

@MainActor open class Engine: NSObject {
  enum SetupState {
    case launching
    case ready
  }
  
  public typealias SetupCompletion = (LaunchOptions) -> Void
  
#if canImport(UIKit)
  public typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]
#elseif canImport(AppKit)
  public typealias LaunchOptions = [String: Any]
#endif
  
  static var sharedEngine: Engine?
  var setupState: SetupState = .launching
  public let info = Bundle.main.runtimeInfo
  
  override init() {
    let model = Engine.makeModel()
    modelService = ModelService(model: model)
    context = ViewContext()
    settingsService = SettingsService(settings: context.settings)
    refreshService = RefreshService(settings: context.settings, model: model)
    launchService = LaunchService()
    super.init()
    context.host = self
    Engine.sharedEngine = self
  }
  
  public required init(coder: NSCoder) {
    fatalError()
  }
  
  open class var shared: Engine {
    return Engine.sharedEngine!
  }
  
  public lazy var updater: Updater = makeUpdater()
  public var context: ViewContext
  public var status: RepoState = RepoState()
  
  var refreshService: RefreshService!
  
#if canImport(UIKit)
  public var rootController: UIViewController?
  public var filePicker: FilePicker?
  open var filePickerClass: FilePicker.Type { return StubFilePicker.self }
#endif
  public let modelService: ModelService
  var observers: [AnyCancellable] = []
  var modelChangeWorkItem: DispatchWorkItem?
  
  public let settingsService: SettingsService
  public let launchService: LaunchService
  open func makeUpdater() -> Updater {
    return Updater()
  }
  
  @objc func changed() {
    modelService.model.load()
  }
  
  class func makeModel() -> Model {
    let isSimulator = Device().platform.isSimulator
    let isUITesting = ProcessInfo.processInfo.environment.isTestingUI
    return isSimulator || isUITesting ? TestModel() : Model([])
  }
  
  public func editNewRepo() {
    context.presentedSheet = .editRepo(nil)
  }
  
  
  open func setUp(withOptions options: LaunchOptions, completion: @escaping SetupCompletion) {
    Task {
      await _setup(withOptions: options, completion: completion)
    }
  }
  
  func _setup(withOptions options: LaunchOptions, completion: @escaping SetupCompletion) async {
    registerDefaultsFromSettingsBundle()
    setupDefaultSettings()
    loadSettings()
    modelService.model.load()
    
    observers.append(
      UserDefaults.standard.onChanged {
        assert(Thread.isMainThread)
        monitoringChannel.log("user defaults changed")
        self.loadSettings()
        self.updateRepoState()
      })
    
    updateRepoState()
    completion(options)
  }
  
  open func updateRepoState() {
    withAnimation {
      status.update(with: modelService.model, context: context)
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
      modelService.model.save()
      self.updateRepoState()
      self.modelChangeWorkItem = nil
    }

    modelChangeWorkItem = workItem
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
  }

  public func settingsDidChange() {
    monitoringChannel.log("settings changed")
    saveSettings()
    updateRepoState()
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
    switch context.settings.readSettings() {
      case .unchanged:
        settingsChannel.debug("Settings unchanged")

      case .authenticationChanged:
        // we've changed authentication method, so reset the refresh controller
        refreshService.resetRefresh()

      case .changed:
        break
    }

    refreshService.resumeRefresh()
  }

  func saveSettings() {
    settingsChannel.debug("Saving settings")
    context.settings.writeSettings()
  }

  public func applyEnvironment<T>(to view: T) -> some View where T: View {
    return
      view
      .environment(context)
      .environment(modelService)
      .environment(modelService.model)
      .environment(settingsService)
      .environment(launchService)
      .environment(updater)
      .environment(status)
      .environment(refreshService)
  }


  open func refreshState(completion: @escaping () -> Void = {}) {
    completion()
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

  func setUpIfNeeded(withOptions options: LaunchOptions) {
    guard setupState == .launching else { return }
    setupState = .ready
    setUp(withOptions: options) { _ in
    }
  }

  /// Loads defaults from `Settings.bundle/Root.plist` when available.
  /// This mirrors the previous behavior from `BasicApplication`.
  func registerDefaultsFromSettingsBundle() {
    guard let bundleURL = Bundle.main.url(forResource: "Settings", withExtension: "bundle") else { return }
    let settingsURL = bundleURL.appendingPathComponent("Root.plist")
    guard let settingsPlist = NSDictionary(contentsOf: settingsURL) else { return }
    guard let preferences = settingsPlist["PreferenceSpecifiers"] as? [NSDictionary] else { return }

    var defaultsToRegister: [String: Any] = [:]
    for item in preferences {
      guard let key = item["Key"] as? String else { continue }
      defaultsToRegister[key] = item["DefaultValue"]
    }
    UserDefaults.standard.register(defaults: defaultsToRegister)
  }
}

#if canImport(UIKit)
  extension Engine: UIApplicationDelegate {
    open func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: LaunchOptions? = nil) -> Bool {
      setUpIfNeeded(withOptions: launchOptions ?? [:])
      return true
    }

    open func applicationWillTerminate(_ application: UIApplication) {
      tearDown()
    }

    open func applicationWillEnterForeground(_ application: UIApplication) {
      refreshState {
      }
    }

  }
#elseif canImport(AppKit)
  extension Engine: NSApplicationDelegate {
    open func applicationDidFinishLaunching(_ notification: Notification) {
      let options = (notification.userInfo as? LaunchOptions) ?? [:]
      setUpIfNeeded(withOptions: options)
    }

    open func applicationWillTerminate(_ notification: Notification) {
      tearDown()
    }
  }
#endif

public extension UserDefaults {
  func onChanged(delay: TimeInterval = 1.0, _ action: @escaping () -> Void) -> AnyCancellable {
    NotificationCenter.default
      .publisher(for: UserDefaults.didChangeNotification, object: self)
      .debounce(for: .seconds(delay), scheduler: RunLoop.main)
      .sink { _ in action() }
  }
}

@Observable
@MainActor class RefreshService {
  init(settings: Settings, model: Model) {
    self.settings = settings
    self.model = model
  }
  
  let settings: Settings
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

@Observable
public class ModelService {
  init(model: Model) {
    self.model = model
  }
  
  public let model: Model
}

@Observable
public class SettingsService {
  init(settings: Settings) {
    self.settings = settings
  }
  
  var settings: Settings
}


@Observable
public class LaunchService {
  func open(url: URL) {
    
  }
  
  func reveal(url: URL) {
    
  }

}
