// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import ApplicationExtensions

#if os(macOS)
import AppKit
typealias AppBase = NSObject
#else
import UIKit
typealias AppBase = BasicApplication
#endif

class AppCommon: AppBase {
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
        
        settingsObserver = NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: nil) { notification in
            self.applySettings()
        }
        
        restoreState()
    }

    override func tearDown() {
        if let observer = settingsObserver {
            NotificationCenter.default.removeObserver(observer, name: UserDefaults.didChangeNotification, object: nil)
        }
    }

    func didSetup(_ window: UIWindow) {
        applySettings()
    }
    
    func applySettings() {
        let intervalSetting = UserDefaults.standard.string(forKey: "RefreshInterval")
        let interval: Double
        switch intervalSetting {
            default: interval = 10.0
        }
        model.refreshInterval = interval
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
    
    
    func makeContentView() -> some View {
        let app = AppDelegate.shared
        return ContentView(repos: app.model)
    }
}

#if os(macOS)

extension AppCommon: NSApplicationDelegate {
    class var shared: AppDelegate {
        NSApp.delegate as! AppDelegate
    }
}

#else

extension AppCommon {
    class var shared: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
}

#endif
