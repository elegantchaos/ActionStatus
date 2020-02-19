// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 13/02/2020.
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
    var filePicker: UIDocumentPickerViewController?
    
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
    
    @objc func changed() {
        restoreState()
    }
    
    override func setup(withOptions options: BasicApplication.LaunchOptions) {
        super.setup(withOptions: options)
        restoreState()
    }
    
    func saveState() {
        repos.save(toDefaultsKey: stateKey)
    }
    
    func restoreState() {
        repos.load(fromDefaultsKey: stateKey)
    }
    
    func pickFile(url: URL) {
        let controller = UIDocumentPickerViewController(url: url, in: UIDocumentPickerMode.moveToService)
        controller.modalPresentationStyle = .overCurrentContext
        rootController?.present(controller, animated: true) {
        }
        filePicker = controller
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
