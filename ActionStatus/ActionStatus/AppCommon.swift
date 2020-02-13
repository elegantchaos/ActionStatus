// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 13/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit
import SwiftUI

class AppCommon: UIResponder, UIApplicationDelegate {
    class var shared: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    @State var repos = defaultRepoSet()

    @State var testRepos = RepoSet([
        Repo("ApplicationExtensions", testState: .failing),
        Repo("Datastore", workflow: "Swift", testState: .passing),
        Repo("DatastoreViewer", workflow: "Build", testState: .failing),
        Repo("Logger", workflow: "tests", testState: .unknown),
        Repo("ViewExtensions", testState: .passing),
    ])
    
    class func defaultRepoSet() -> RepoSet {
        return RepoSet([
            Repo("ApplicationExtensions"),
            Repo("Datastore", workflow: "Swift"),
            Repo("DatastoreViewer", workflow: "Build"),
            Repo("Logger", workflow: "tests"),
            Repo("ViewExtensions"),
        ])
    }
}
