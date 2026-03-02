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

@Observable
@MainActor open class Engine: NSObject {
  @ObservationIgnored @AppStorage(.sortModeKey) public var sortMode

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


  var setupState: SetupState = .launching
  public let info = AppInfo()

  override init() {
    let model = Engine.makeModel()
    self.sheetService = SheetService()
    self.modelService = ModelService(model: model)
    self.settingsService = SettingsService()
    self.refreshService = RefreshService(model: model)
    self.launchService = LaunchService()
    super.init()
  }
  
  public required init(coder: NSCoder) {
    fatalError()
  }
  
  public var status: RepoState = RepoState()
  public var sheetService: SheetService
  
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
  
  @objc func changed() {
    modelService.model.load()
  }
  
  class func makeModel() -> Model {
    let isSimulator = Device().platform.isSimulator
    let isUITesting = ProcessInfo.processInfo.environment.isTestingUI
    return isSimulator || isUITesting ? TestModel() : Model([])
  }
  
  public func editNewRepo() {
    sheetService.presentedSheet = .editRepo(nil)
  }
  
  
  open func setUp(withOptions options: LaunchOptions, completion: @escaping SetupCompletion) {
    Task {
      await _setup(withOptions: options, completion: completion)
    }
  }
  
  func _setup(withOptions options: LaunchOptions, completion: @escaping SetupCompletion) async {
    registerDefaultsFromSettingsBundle()
    modelService.model.load()
    
    observers.append(
      UserDefaults.standard.onChanged {
        assert(Thread.isMainThread)
        monitoringChannel.log("user defaults changed")
        self.updateRepoState()
      })
    
    updateRepoState()
    completion(options)
  }
  
  open func updateRepoState() {
    let sorted = modelService.model.repos(sortedBy: sortMode)
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
      modelService.model.save()
      self.updateRepoState()
      self.modelChangeWorkItem = nil
    }

    modelChangeWorkItem = workItem
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
  }

  public func applyEnvironment<T>(@ViewBuilder to view: () -> T) -> some View where T: View {
    return
      view()
      .environment(modelService)
      .environment(modelService.model)
      .environment(settingsService)
      .environment(launchService)
      .environment(status)
      .environment(refreshService)
      .environment(sheetService)
      .environment(self)
  }


  open func refreshState(completion: @escaping () -> Void = {}) {
    completion()
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

extension CGFloat {
  static let padding: CGFloat = 10
}
