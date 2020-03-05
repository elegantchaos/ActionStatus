// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ActionStatusCore
import ApplicationExtensions
import Logger
import SwiftUI

let settingsChannel = Channel("Settings")

internal extension String {
    static let refreshIntervalKey = "RefreshInterval"
}

class Application: BasicApplication {

    #if DEBUG
        let stateKey = "StateDebug"
    #else
        let stateKey = "State"
    #endif
    
    var rootController: UIViewController?
    var settingsObserver: Any?
    
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
    
    func saveWorkflow(named name: String, source: String) {
        if let data = source.data(using: .utf8) {
            do {
                let url = UIApplication.newDocumentURL(name: name, withPathExtension: "yml", makeUnique: false)
                try data.write(to: url)
                let model = Application.shared.model
                
                #if targetEnvironment(macCatalyst)
                // ugly hack - the SwiftUI sheet doesn't work properly on the mac
                model.hideComposeWindow()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .seconds(1))) {
                    Application.shared.pickFile(url: url)
                }
                #else
                model.exportURL = url
                model.exportYML = source
                model.isSaving = true
                #endif
            } catch {
                print(error)
            }
        }
    }
}
