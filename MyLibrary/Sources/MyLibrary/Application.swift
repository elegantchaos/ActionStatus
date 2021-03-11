// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ApplicationExtensions
import Combine
import Keychain
import Logger
import SheetController
import SwiftUI
import SwiftUIExtensions
import Hardware
import Files

public let settingsChannel = Channel("Settings")

open class Application: BasicApplication, ApplicationHost {
    public static var instance: Application {
        UIApplication.shared.delegate as! Application
    }

    #if DEBUG
    let stateKey = "StateDebug"
    #else
    let stateKey = "State"
    #endif
    
    public lazy var updater: Updater = makeUpdater()
    public lazy var viewState = makeViewState()

    public var refreshController: RefreshController? = nil
    public var rootController: UIViewController?
    var settingsObserver: Any?
    var exportWorkflow: Generator.Output? = nil
    public var filePicker: FilePicker?
    open var filePickerClass: FilePicker.Type { return StubFilePicker.self }
    public var model = makeModel()
    var stateChanged = false
    var modelWatcher: AnyCancellable?
    var stateWatcher: AnyCancellable?
    var applyingSettings = false
    var savingSettings = false
    
    public let sheetController = SheetController()
    
    func makeViewState() -> ViewState {
        return ViewState(host: self)
    }
    
    open func makeUpdater() -> Updater {
        return Updater()
    }
    
    @objc func changed() {
        restoreState()
    }
    
    func makeRefreshController() -> RefreshController {
        do {
            let token = try Keychain.default.getToken(user: viewState.githubUser, server: viewState.githubServer)
            let controller = OctoidRefreshController(model: model, viewState: viewState, token: token)
            refreshChannel.log("Using github refresh controller for \(viewState.githubUser)/\(viewState.githubServer)")
            return controller
        } catch {
            refreshChannel.log("Couldn't get token: \(error). Defaulting to simple refresh controller.")
            return SimpleRefreshController(model: model, viewState: viewState)
        }
    }
    
    class func makeModel() -> Model {
        let isSimulator = Device.main.system.platform.isSimulator
        let isUITesting = ProcessInfo.processInfo.environment.isTestingUI
        return isSimulator || isUITesting ? TestModel() : Model([])
    }
    
    open override func setUp(withOptions options: BasicApplication.LaunchOptions, completion: @escaping BasicApplication.SetupCompletion) {
        super.setUp(withOptions: options) { [self] options in
            DispatchQueue.main.async {
                sheetController.environmentSetter = { view in AnyView(self.applyEnvironment(to: view)) }
                
                UserDefaults.standard.register(defaults: [
                    .refreshIntervalKey: RefreshRate.automatic.rawValue,
                    .displaySizeKey: DisplaySize.automatic.rawValue
                ])
                
                restoreState()
                completion(options)
            }
        }
        
    }
    
    public override func tearDown() {
        if let observer = settingsObserver {
            NotificationCenter.default.removeObserver(observer, name: UserDefaults.didChangeNotification, object: nil)
        }
    }
    
    open func didSetUp(_ window: UIWindow) {
        applySettings()

        settingsObserver = NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: nil) { notification in
            if !self.savingSettings {
                self.applySettings()
            }
        }
        
        modelWatcher = model
            .objectWillChange
            .debounce(for: 1.0, scheduler: RunLoop.main)
            .sink {
            self.stateWasEdited()
        }
        
        stateWatcher = viewState
            .objectWillChange
            .debounce(for: 1.0, scheduler: RunLoop.main)
            .sink() { value in
            if !self.applyingSettings {
                self.saveSettings()
            }
        }
    }
    
    open func applySettings() {
        refreshController?.pause()
        let oldToken = try? Keychain.default.getToken(user: viewState.githubUser, server: viewState.githubServer)
        applyingSettings = true
        let defaults = UserDefaults.standard
        if let rate = RefreshRate(rawValue: defaults.integer(forKey: .refreshIntervalKey)) {
            viewState.refreshRate = rate
        }
        
        if let size = DisplaySize(rawValue: defaults.integer(forKey: .displaySizeKey)) {
            viewState.displaySize = size
        }

        viewState.githubUser = defaults.string(forKey: .githubUserKey) ?? ""
        viewState.githubServer = defaults.string(forKey: .githubServerKey) ?? "api.github.com"
        
        settingsChannel.log("\(String.refreshIntervalKey) is \(viewState.refreshRate)")
        settingsChannel.log("\(String.displaySizeKey) is \(viewState.displaySize)")
        applyingSettings = false
        
        let newToken = try? Keychain.default.getToken(user: viewState.githubUser, server: viewState.githubServer)

        if oldToken != newToken {
            // we've changed the github settings, so we need to rebuild the refresh controller
            refreshController = makeRefreshController()
        }
        
        refreshController?.resume()
    }
  
    func saveSettings() {
        savingSettings = true
        let defaults = UserDefaults.standard
        defaults.set(viewState.refreshRate.rawValue, forKey: .refreshIntervalKey)
        defaults.set(viewState.displaySize.rawValue, forKey: .displaySizeKey)
        defaults.set(viewState.githubUser, forKey: .githubUserKey)
        defaults.set(viewState.githubServer, forKey: .githubServerKey)
        // NB: github token is stored in the keychain
        savingSettings = false
    }
    
    public func applyEnvironment<T>(to view: T) -> some View where T: View {
        return view
            .environmentObject(viewState)
            .environmentObject(model)
            .environmentObject(updater)
            .environmentObject(sheetController)
    }

    public func stateWasEdited() {
        DispatchQueue.main.async {
            if !self.stateChanged {
                modelChannel.log("Model Changed") // TODO: should be app channel
            }
            self.stateChanged = true
            self.saveState()
        }
    }
    
    public func saveState() {
        DispatchQueue.main.async { [self] in
            if stateChanged {
                didRefresh()
                model.save(toDefaultsKey: stateKey)
                stateChanged = false
            }
        }
    }
    
    func restoreState() {
        model.load(fromDefaultsKey: stateKey)
    }
    
    func pauseRefresh() {
        refreshController?.pause()
    }
    
    func resumeRefresh() {
        refreshController?.resume()
    }
    
    open func didRefresh() {
        
    }

    public func openGithub(with repo: Repo, at location: Repo.GithubLocation = .workflow) {
        UIApplication.shared.open(repo.githubURL(for: location))
    }
    
    func pickerForSavingWorkflow() -> FilePicker {
        let workflow = exportWorkflow!
        
        let defaultURL: URL?
        if let identifier = Device.main.identifier {
            defaultURL = workflow.repo.url(forDevice: identifier)
        } else {
            defaultURL = nil
        }
            
        let picker = filePickerClass.init(forOpeningFolderStartingIn: defaultURL) { urls in
            self.save(output: workflow, to: urls.first)
        }
        
        return picker
    }
    
    public func save(output: Generator.Output) {
        exportWorkflow = output

        sheetController.dismiss()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .seconds(1))) {
            #if targetEnvironment(macCatalyst)
            Application.instance.presentPicker(self.pickerForSavingWorkflow()) // ugly hack - the SwiftUI sheet doesn't work properly on the mac
            #else
            self.sheetController.show() {
                DocumentPickerViewController(picker: self.pickerForSavingWorkflow())
            }
            #endif
        }
    }
    
    public func presentPicker(_ picker: FilePicker) {
        rootController?.present(picker, animated: true) {
        }
        filePicker = picker
    }
    
    func save(output: Generator.Output, to rootURL: URL?) {
        if let rootURL = rootURL {
            rootURL.accessSecurityScopedResource(withPathComponents: [".github", "workflows", "\(output.repo.workflow).yml"]) { url in
                var error: NSError? = nil
                NSFileCoordinator().coordinate(writingItemAt: url, error: &error) { (url) in
                    do {
                        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                        try output.data.write(to: url)
                        if let identifier = Device.main.identifier {
                            model.remember(url: rootURL, forDevice: identifier, inRepo: output.repo)
                        }
                    } catch {
                        print(error)
                    }
                }
            }

            if !output.header.isEmpty {
                rootURL.accessSecurityScopedResource(withPathComponents: ["README.md"]) { url in
                    var error: NSError? = nil
                    NSFileCoordinator().coordinate(writingItemAt: url, error: &error) { (url) in
                        do {
                            var readme = try String(contentsOf: url, encoding: .utf8)
                            if let range = readme.range(of: output.delimiter) {
                                readme.removeSubrange(readme.startIndex ..< range.upperBound)
                            }
                            readme.insert(contentsOf: output.header, at: readme.startIndex)
                            let data = readme.data(using: .utf8)
                            try data?.write(to: url)
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            
        }
    }
}
