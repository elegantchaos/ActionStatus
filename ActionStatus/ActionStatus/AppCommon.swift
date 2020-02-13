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
    
    @State var repos = loadRepos()

    @State var testRepos = RepoSet([
        Repo("ApplicationExtensions", testState: .failing),
        Repo("Datastore", workflow: "Swift", testState: .passing),
        Repo("DatastoreViewer", workflow: "Build", testState: .failing),
        Repo("Logger", workflow: "tests", testState: .unknown),
        Repo("ViewExtensions", testState: .passing),
    ])
    
    class func loadRepos() -> RepoSet {
        if let array = UserDefaults.standard.array(forKey: "Repos") {
            var loadedRepos: [Repo] = []
            for item in array {
                if let string = item as? String {
                    let values = string.split(separator: ",").map({String($0)})
                    if values.count == 3 {
                        let repo = Repo(values[0], owner: values[1], workflow: values[2])
                        loadedRepos.append(repo)
                    }
                }
            }
            return RepoSet(loadedRepos)
        } else {
            return RepoSet([
                Repo("ApplicationExtensions"),
                Repo("Datastore", workflow: "Swift"),
                Repo("DatastoreViewer", workflow: "Build"),
                Repo("Logger", workflow: "tests"),
                Repo("ViewExtensions"),
            ])
        }
    }

    func saveRepos() {
        var strings: [String] = []
        for repo in repos.items {
            let string = "\(repo.name),\(repo.owner),\(repo.workflow)"
            strings.append(string)
        }
        UserDefaults.standard.set(strings, forKey: "Repos")
    }
    
}
