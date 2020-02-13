// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 12/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

class RepoSet: ObservableObject {
    typealias RepoList = [Repo]
    
    @Published var items: [Repo]
    
    init(_ repos: [Repo]) {
        self.items = repos
    }
    
    func load(fromDefaultsKey key: String) {
        if let array = UserDefaults.standard.array(forKey: key) {
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
            items = loadedRepos
        }
    }
    
    func save(toDefaultsKey key: String) {
        var strings: [String] = []
        for repo in items {
            let string = "\(repo.name),\(repo.owner),\(repo.workflow)"
            strings.append(string)
        }
        UserDefaults.standard.set(strings, forKey: key)
    }

    func reload() {
        var reloaded: [Repo] = []
        for repo in items {
            var updaated = repo
            updaated.reload()
            reloaded.append(updaated)
        }
        items = reloaded
    }

    func addRepo() {
        let repo = Repo()
        items.append(repo)
    }
}
