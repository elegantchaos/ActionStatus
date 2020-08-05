// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ActionStatusCore
import ApplicationExtensions
import Combine
import Keychain
import Logger
import SwiftUI
import SwiftUIExtensions
import Hardware
import Files

let settingsChannel = Channel("Settings")

internal extension String {
    static let refreshIntervalKey = "RefreshInterval"
    static let textSizeKey = "TextSize"
}

class Application: BasicApplication, ApplicationHost {
    
    #if DEBUG
    let stateKey = "StateDebug"
    #else
    let stateKey = "State"
    #endif
    
    lazy var updater: Updater = makeUpdater()
    lazy var refreshController = makeRefreshController()
    lazy var viewState = makeViewState()

    var rootController: UIViewController?
    var settingsObserver: Any?
    var exportWorkflow: Generator.Output? = nil
    var filePicker: FilePicker?
    var filePickerClass: FilePicker.Type { return StubFilePicker.self }
    var model = makeModel()
    var modelDirty = false
    var modelWatcher: AnyCancellable?
    
    let sheetController = SheetController()
    
    func makeViewState() -> ViewState {
        return ViewState(host: self)
    }
    
    func makeUpdater() -> Updater {
        return Updater()
    }
    
    @objc func changed() {
        restoreState()
    }
    
    func makeRefreshController() -> RefreshController {
        let user = "sam@elegantchaos.com" // TODO: expose token settings in preferences
        let server = "api.github.com"
        do {
//            try Keychain.default.addToken("<token>", user: user, server: server)
            let token = try Keychain.default.getToken(user: user, server: server)
            return OctoidRefreshController(model: model, token: token)
        } catch {
            modelChannel.log("Couldn't get token: \(error). Defaulting to simple refresh.")
            return SimpleRefreshController(model: model)
        }
    }
    
    class func makeModel() -> Model {
        let isSimulator = Device.main.system.platform.isSimulator
        let isUITesting = ProcessInfo.processInfo.environment.isTestingUI
        return isSimulator || isUITesting ? TestModel() : Model([])
    }
    
    override func setUp(withOptions options: BasicApplication.LaunchOptions) {
        super.setUp(withOptions: options)
        
        sheetController.environmentSetter = { view in AnyView(self.applyEnvironment(to: view)) }
        
        UserDefaults.standard.register(defaults: [
            .refreshIntervalKey: 60,
            .textSizeKey: ViewState.TextSize.automatic.rawValue
        ])
        
        restoreState()
    }
    
    override func tearDown() {
        if let observer = settingsObserver {
            NotificationCenter.default.removeObserver(observer, name: UserDefaults.didChangeNotification, object: nil)
        }
    }
    
    func didSetUp(_ window: UIWindow) {
        applySettings()
        settingsObserver = NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: nil) { notification in
            self.applySettings()
        }
        
        modelWatcher = model.objectWillChange.sink {
            self.stateWasEdited()
        }
    }
    
    func applySettings() {
        let defaults = UserDefaults.standard
        let interval = defaults.integer(forKey: .refreshIntervalKey)
        if interval > 0 {
            model.refreshInterval = Double(interval)
        }
        
        viewState.repoTextSize = ViewState.TextSize(rawValue: defaults.integer(forKey: .textSizeKey)) ?? .automatic

        settingsChannel.log("\(String.refreshIntervalKey) is \(interval)")
    }
  
    func applyEnvironment<T>(to view: T) -> some View where T: View {
        return view
            .environmentObject(viewState)
            .environmentObject(model)
            .environmentObject(updater)
            .environmentObject(sheetController)
    }

    func stateWasEdited() {
        DispatchQueue.main.async {
            if !self.modelDirty {
                modelChannel.log("Needs Saving")
            }
            self.modelDirty = true
            self.saveState()
        }
    }
    
    func saveState() {
        DispatchQueue.main.async { [self] in
            if modelDirty {
                model.save(toDefaultsKey: stateKey)
                modelDirty = false
            }
        }
    }
    
    func restoreState() {
        model.load(fromDefaultsKey: stateKey)
    }
    
    func pauseRefresh() {
        refreshController.pause()
    }
    
    func resumeRefresh() {
        refreshController.resume()
    }
    
    func didRefresh() {
        
    }

    func openGithub(with repo: Repo, at location: Repo.GithubLocation = .workflow) {
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
    
    func save(output: Generator.Output) {
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
