// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ApplicationExtensions
import Combine
import Files
import Keychain
import Hardware
import Logger
import SheetController
import SwiftUI
import SwiftUIExtensions
import UserDefaultsExtensions

public let settingsChannel = Channel("Settings")
public let monitoringChannel = Channel("Monitoring")

open class Application: BasicApplication, ApplicationHost {
    override open class var shared: Application {
        UIApplication.shared.delegate as! Application
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
    public var rootController: UIViewController?
    var exportWorkflow: Generator.Output? = nil
    public var filePicker: FilePicker?
    open var filePickerClass: FilePicker.Type { return StubFilePicker.self }
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
        
        if settings.githubAuthentication {
            do {
                let token = try Keychain.default.password(for: settings.githubUser, on: settings.githubServer)
                let controller = OctoidRefreshController(model: model, token: token)
                refreshChannel.log("Using github refresh controller for \(settings.githubUser)/\(settings.githubServer)")
                return controller
            } catch {
                refreshChannel.log("Couldn't get token: \(error). Defaulting to simple refresh controller.")
            }
        } else {
            refreshChannel.log("Authentication is disabled. Defaulting to simple refresh controller.")
        }

        // fall back to simple non-authenticated mode
        return SimpleRefreshController(model: model)
    }
    
    class func makeModel() -> Model {
        let isSimulator = Device.main.system.platform.isSimulator
        let isUITesting = ProcessInfo.processInfo.environment.isTestingUI
        return isSimulator || isUITesting ? TestModel() : Model([])
    }
    
    public func editNewRepo() {
        sheetController.show() {
            EditView(repo: nil)
        }
    }
    

    open override func setUp(withOptions options: BasicApplication.LaunchOptions, completion: @escaping BasicApplication.SetupCompletion) {
        super.setUp(withOptions: options) { [self] options in
            DispatchQueue.main.async {
                sheetController.environmentSetter = { view in AnyView(self.applyEnvironment(to: view)) }

                setupDefaultSettings()
                loadSettings()
                restoreState()

                observers.append(UserDefaults.standard.onChanged {
                    monitoringChannel.log("user defaults changed")
                    self.loadSettings()
                    self.updateRepoState()
                })

                observers.append(
                    model
                        .objectWillChange
                        .debounce(for: 0.1, scheduler: RunLoop.main)
                        .sink {
                            monitoringChannel.log("model changed")
                            self.saveState()
                            self.updateRepoState()
                        })
                
                observers.append(
                    context
                        .objectWillChange
                        .debounce(for: 0.1, scheduler: RunLoop.main)
                        .sink() { value in
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
    
    public override func tearDown() {
        observers = []
    }
    
    open func setupDefaultSettings() {
        UserDefaults.standard.register(defaults: [
            .refreshIntervalKey: RefreshRate.automatic.rawValue,
            .displaySizeKey: DisplaySize.automatic.rawValue,
            .sortModeKey: SortMode.state.rawValue
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
        return view
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
        refreshController?.pause()
    }
    
    public func resumeRefresh() {
        if refreshController == nil {
            refreshController = makeRefreshController()
        }

        refreshController?.resume(rate: settings.refreshRate.rate)
    }
    
    func resetRefresh() {
        pauseRefresh()
        refreshController = nil
    }
    
    public func open(url: URL) {
        UIApplication.shared.open(url)
    }

    open func reveal(url: URL) {
        UIApplication.shared.open(url)
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
            Application.shared.presentPicker(self.pickerForSavingWorkflow()) // ugly hack - the SwiftUI sheet doesn't work properly on the mac
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
