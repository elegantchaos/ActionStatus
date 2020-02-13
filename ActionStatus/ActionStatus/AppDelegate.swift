// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


import UIKit
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
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
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

