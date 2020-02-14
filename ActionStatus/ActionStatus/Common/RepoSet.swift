// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 12/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

class RepoSet: ObservableObject {
    typealias RepoList = [Repo]
    
    let store: NSUbiquitousKeyValueStore
    let key: String = "State"
    
    @Published var items: [Repo]
    
    init(_ repos: [Repo], store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default) {
        self.store = store
        self.items = repos
        NotificationCenter.default.addObserver(self, selector: #selector(changed), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
    }
    
    @objc func changed() {
        load(fromDefaultsKey: key)
    }

    func load(fromDefaultsKey key: String) {
        if let array = store.array(forKey: key) {
            var loadedRepos: [Repo] = []
            for item in array {
                if let string = item as? String {
                    let values = string.split(separator: ",").map({String($0)})
                    if values.count == 4 {
                        let repo = Repo(values[0], owner: values[1], workflow: values[2], id: UUID(uuidString: values[3]))
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
            let string = "\(repo.name),\(repo.owner),\(repo.workflow),\(repo.id.uuidString)"
            strings.append(string)
        }
        store.set(strings, forKey: key)
    }

    func refresh() {
        DispatchQueue.global(qos: .background).async {
            var reloaded: [Repo] = []
            for repo in self.items {
                var updated = repo
                updated.reload()
                reloaded.append(updated)
            }
            DispatchQueue.main.async {
                self.items = reloaded
            }
        }
    }

    func addRepo() {
        let repo = Repo()
        items.append(repo)
    }
    
    func remove(repo: Repo) {
        if let index = items.firstIndex(of: repo) {
            var updated = items
            updated.remove(at: index)
            items = updated
        }
    }
}
