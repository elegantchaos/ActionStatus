// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 13/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

#if os(macOS)
import AppKit
typealias AppBase = NSObject
#else
import UIKit
typealias AppBase = UIResponder
#endif

class AppCommon: AppBase {
    let stateKey = "State"
    
    @State var repos = RepoSet([])

    @State var testRepos = RepoSet([
        Repo("ApplicationExtensions", owner: "elegantchaos", workflow: "Tests", state: .failing),
        Repo("Datastore", owner: "elegantchaos", workflow: "Swift", state: .passing),
        Repo("DatastoreViewer", owner: "elegantchaos", workflow: "Build", state: .failing),
        Repo("Logger", owner: "elegantchaos", workflow: "tests", state: .unknown),
        Repo("ViewExtensions", owner: "elegantchaos", workflow: "Tests", state: .passing),
    ])
    
    class func defaultRepoSet() -> RepoSet {
        return RepoSet([
            Repo("ApplicationExtensions", owner: "elegantchaos", workflow: "Tests"),
            Repo("Datastore", owner: "elegantchaos", workflow: "Swift"),
            Repo("DatastoreViewer", owner: "elegantchaos", workflow: "Build"),
            Repo("Logger", owner: "elegantchaos", workflow: "tests"),
            Repo("ViewExtensions", owner: "elegantchaos", workflow: "Tests"),
        ])
    }
    
    func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(changed), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
    }
    
    @objc func changed() {
        restoreState()
    }
    
    func saveState() {
        repos.save(toDefaultsKey: stateKey)
    }
    
    func restoreState() {
        repos.load(fromDefaultsKey: stateKey)
    }
}

#if os(macOS)

extension AppCommon: NSApplicationDelegate {
    class var shared: AppDelegate {
        NSApp.delegate as! AppDelegate
    }
}

#else

extension AppCommon: UIApplicationDelegate {
    class var shared: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
}

#endif
