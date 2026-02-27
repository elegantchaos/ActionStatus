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

open class Engine: NSObject, ApplicationHost {
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
    super.init()
    Engine.sharedEngine = self
  }

  public required init(coder: NSCoder) {
    fatalError()
  }

  open class var shared: Engine {
    return Engine.sharedEngine!
  }

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
  var modelChangeWorkItem: DispatchWorkItem?

  var settings: Settings {
    context.settings
  }

  func makeViewState() -> ViewContext {
    return ViewContext(host: self)
  }

  open func makeUpdater() -> Updater {
    return Updater()
  }

  @objc func changed() {
    model.load()
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

  class func makeModel() -> Model {
    let isSimulator = Device().platform.isSimulator
    let isUITesting = ProcessInfo.processInfo.environment.isTestingUI
    return isSimulator || isUITesting ? TestModel() : Model([])
  }

  public func editNewRepo() {
    context.presentedSheet = .editRepo(nil)
  }


  open func setUp(withOptions options: LaunchOptions, completion: @escaping SetupCompletion) {
    DispatchQueue.main.async { [self] in
      registerDefaultsFromSettingsBundle()
      setupDefaultSettings()
      loadSettings()
      model.load()

      observers.append(
        UserDefaults.standard.onChanged {
          assert(Thread.isMainThread)
          monitoringChannel.log("user defaults changed")
          self.loadSettings()
          self.updateRepoState()
        })

      observeModelChanges()
      observeSettingsChanges()

      updateRepoState()
      completion(options)
    }
  }

  open func updateRepoState() {
    withAnimation {
      status.update(with: model, context: context)
    }
  }

  open func tearDown() {
    observers = []
    modelChangeWorkItem?.cancel()
    modelChangeWorkItem = nil
  }

  func observeModelChanges() {
    withObservationTracking(
      {
        _ = model.items
      },
      onChange: { [weak self] in
        DispatchQueue.main.async { [weak self] in
          guard let self else { return }
          self.modelDidChange()
          self.observeModelChanges()
        }
      })
  }

  func observeSettingsChanges() {
    withObservationTracking(
      {
        _ = context.settings
      },
      onChange: { [weak self] in
        DispatchQueue.main.async { [weak self] in
          guard let self else { return }
          monitoringChannel.log("settings changed")
          self.saveSettings()
          self.updateRepoState()
          self.observeSettingsChanges()
        }
      })
  }

  func modelDidChange() {
    modelChangeWorkItem?.cancel()
    let workItem = DispatchWorkItem { [weak self] in
      guard let self else { return }
      monitoringChannel.log("model changed")
      model.save()
      self.updateRepoState()
      self.modelChangeWorkItem = nil
    }

    modelChangeWorkItem = workItem
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
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
        resetRefresh()

      case .changed:
        break
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
      .environment(context)
      .environment(model)
      .environment(updater)
      .environment(status)
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
