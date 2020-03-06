// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ActionStatusCore
import ApplicationExtensions
import Logger
import SwiftUI
import URLExtensions
import Hardware

let settingsChannel = Channel("Settings")

internal extension String {
    static let refreshIntervalKey = "RefreshInterval"
}

class ViewState: ObservableObject {
    @Published var hasAlert = false
    @Published var isSaving = false
    @Published var composingID: UUID? = nil
}

class Application: BasicApplication {
    
    #if DEBUG
    let stateKey = "StateDebug"
    #else
    let stateKey = "State"
    #endif
    
    var rootController: UIViewController?
    var settingsObserver: Any?
    var exportData: Data? = nil
    var exportRepo: UUID? = nil
    var viewState = ViewState()
    var filePicker: FilePicker?
    var filePickerClass: FilePicker.Type { return StubFilePicker.self }

    @State var model = Model([])
    
    @State var testRepos = Model([
        Repo("ApplicationExtensions", owner: "elegantchaos", workflow: "Tests", state: .failing),
        Repo("Datastore", owner: "elegantchaos", workflow: "Swift", state: .passing),
        Repo("DatastoreViewer", owner: "elegantchaos", workflow: "Build", state: .failing),
        Repo("Logger", owner: "elegantchaos", workflow: "tests", state: .unknown),
        Repo("ViewExtensions", owner: "elegantchaos", workflow: "Tests", state: .passing),
    ])
    
    @objc func changed() {
        restoreState()
    }
    
    override func setUp(withOptions options: BasicApplication.LaunchOptions) {
        super.setUp(withOptions: options)
        
        UserDefaults.standard.register(defaults: [
            .refreshIntervalKey : 60
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
    }
    
    func applySettings() {
        let interval = UserDefaults.standard.integer(forKey: .refreshIntervalKey)
        if interval > 0 {
            model.refreshInterval = Double(interval)
        }
        
        settingsChannel.log("\(String.refreshIntervalKey) is \(interval)")
    }
    
    func stateWasEdited() {
        saveState()
        model.refresh()
    }
    
    func saveState() {
        model.save(toDefaultsKey: stateKey)
    }
    
    func restoreState() {
        model.load(fromDefaultsKey: stateKey)
    }
    
    func openGithub(with repo: Repo, at location: Repo.GithubLocation = .workflow) {
        UIApplication.shared.open(repo.githubURL(for: location))
    }
    
    func pickerForSavingWorkflow() -> FilePicker {
        let data = exportData!
        let repo = model.repo(withIdentifier: exportRepo!)!
        
        let defaultURL: URL?
        if let identifier = Device.main.identifier {
            defaultURL = repo.url(forDevice: identifier)
        } else {
            defaultURL = nil
        }
            
        let picker = filePickerClass.init(forOpeningFolderStartingIn: defaultURL) { urls in
            self.saveWorkflow(data, for: repo, to: urls.first)
        }
        
        return picker
    }
    
    func saveWorkflow(_ source: String, for repo: Repo) {
        if let data = source.data(using: .utf8) {
            exportData = data
            exportRepo = repo.id

            #if targetEnvironment(macCatalyst)
            // ugly hack - the SwiftUI sheet doesn't work properly on the mac
            viewState.hasAlert = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .seconds(1))) {
                Application.shared.presentPicker(self.pickerForSavingWorkflow())
            }
            #else
            model.isSaving = true
            #endif
        }
    }
    
    func saveWorkflow(_ data: Data, for repo: Repo, to rootURL: URL?) {
        if let rootURL = rootURL {
            rootURL.accessSecurityScopedResource(withPathComponents: [".github", "workflows", "\(repo.workflow).yml"]) { url in
                var error: NSError? = nil
                NSFileCoordinator().coordinate(readingItemAt: url, error: &error) { (url) in
                    do {
                        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                        try data.write(to: url)
                        if let identifier = Device.main.identifier {
                            model.remember(url: rootURL, forDevice: identifier, inRepo: repo)
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}
