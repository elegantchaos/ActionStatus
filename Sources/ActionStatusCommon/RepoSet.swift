// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 12/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

class RepoSet: ObservableObject {
    typealias RepoList = [Repo]
    typealias RefreshBlock = () -> Void
    
    let store: NSUbiquitousKeyValueStore
    let key: String = "State"
    var block: RefreshBlock?
    var timer: Timer?
    
    @Published var items: [Repo]
    
    init(_ repos: [Repo], store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default, block: RefreshBlock? = nil) {
        self.block = block
        self.store = store
        self.items = repos
        NotificationCenter.default.addObserver(self, selector: #selector(changed), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
    }
    
    @objc func changed() {
        load(fromDefaultsKey: key)
    }

    var failingCount: Int {
        var count = 0
        for repo in items {
            if repo.state == .failing {
                count += 1
            }
        }
        return count
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
        scheduleRefresh(after: 0)
    }
        
    func scheduleRefresh(after interval: TimeInterval) {
        timer?.invalidate()
        print("Will refresh in \(interval) seconds.")
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            self.doRefresh()
        }
    }
    
    func doRefresh() {
        DispatchQueue.global(qos: .background).async {
            print("refreshing")
            var reloaded: [Repo] = []
            for repo in self.items {
                var updated = repo
                updated.reload()
                reloaded.append(updated)
            }
            reloaded.sort { (r1, r2) -> Bool in
                if (r1.state == r2.state) {
                    return r1.name < r2.name
                }
                
                if (r1.state == .failing) {
                    return true
                }
                
                return r1.name < r2.name
            }
            
            DispatchQueue.main.async {
                self.items = reloaded
                self.block?()
                self.scheduleRefresh(after: 10.0)
            }
        }
    }

    func addRepo() -> Repo {
        let repo = Repo()
        items.append(repo)
        return repo
    }
    
    func remove(repo: Repo) {
        if let index = items.firstIndex(of: repo) {
            var updated = items
            updated.remove(at: index)
            items = updated
        }
    }
}
