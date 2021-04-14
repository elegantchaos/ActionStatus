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
    public lazy var viewState = makeViewState()
    public var status: RepoState = RepoState()
    
    public var refreshController: RefreshController? = nil
    public var rootController: UIViewController?
    var exportWorkflow: Generator.Output? = nil
    public var filePicker: FilePicker?
    open var filePickerClass: FilePicker.Type { return StubFilePicker.self }
    public var model = makeModel()
    var observers: [AnyCancellable] = []
    
    var settings: Settings {
        viewState.settings
    }

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
        if settings.githubAuthentication {
            do {
                let token = try Keychain.default.getToken(user: settings.githubUser, server: settings.githubServer)
                let controller = OctoidRefreshController(model: model, viewState: viewState, token: token)
                refreshChannel.log("Using github refresh controller for \(settings.githubUser)/\(settings.githubServer)")
                return controller
            } catch {
                refreshChannel.log("Couldn't get token: \(error). Defaulting to simple refresh controller.")
            }
        } else {
            refreshChannel.log("Authentication is disabled. Defaulting to simple refresh controller.")
        }

        // fall back to simple non-authenticated mode
        return SimpleRefreshController(model: model, viewState: viewState)

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
                    print("user defaults changed")
                    self.loadSettings()
                    self.updateRepoState()
                })

                observers.append(
                    model
                        .objectWillChange
                        .debounce(for: 0.1, scheduler: RunLoop.main)
                        .sink {
                            print("model changed")
                            self.saveState()
                            self.updateRepoState()
                        })
                
                observers.append(
                    viewState
                        .objectWillChange
                        .debounce(for: 0.1, scheduler: RunLoop.main)
                        .sink() { value in
                            print("view state changed")
                            self.saveSettings()
                            self.updateRepoState()
                        })
                
                updateRepoState()
                completion(options)
            }
        }
        
    }
    
    open func updateRepoState() {
        status.update(with: model, viewState: viewState)
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
        if viewState.settings.readSettings() == .authenticationChanged {
            // we've changed the github settings, so we need to rebuild the refresh controller
            resetRefresh()
        }
        resumeRefresh()
    }
  
    func saveSettings() {
        settingsChannel.debug("Saving settings")
        viewState.settings.writeSettings()
    }
    
    public func applyEnvironment<T>(to view: T) -> some View where T: View {
        return view
            .environmentObject(viewState)
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
    
    func pauseRefresh() {
        refreshController?.pause()
    }
    
    func resumeRefresh() {
        refreshController?.resume()
    }
    
    func resetRefresh() {
        refreshController = makeRefreshController()
    }
    
    public func open(url: URL) {
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