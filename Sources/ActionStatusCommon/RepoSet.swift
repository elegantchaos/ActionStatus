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
    var composingIndex: Int?
    var exportURL: URL?
    var exportYML: String?

    @Published var items: [Repo]
    @Published var isComposing = false
    @Published var isSaving = false

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
    
    func showComposeWindow(for repo: Repo) {
        if let index = items.firstIndex(of: repo) {
            composingIndex = index
            isComposing = true
        }
    }
    
    func hideComposeWindow() {
        isComposing = false
    }
    
    func repoToCompose() -> Repo {
        return items[composingIndex!]
    }
    
    func load(fromDefaultsKey key: String) {
        if let repoIDs = store.array(forKey: key) as? Array<String> {
            var loadedRepos: [Repo] = []
            for repoID in repoIDs {
                if let dict = store.dictionary(forKey: repoID) {
                    if let id = dict["id"] as? String,
                        let name = dict["name"] as? String,
                        let owner = dict["owner"] as? String,
                        let workflow = dict["workflow"] as? String,
                        let stateRaw = dict["state"] as? Int,
                        let state = Repo.State(rawValue: stateRaw) {
                        let repo = Repo(name, owner: owner, workflow: workflow, id: UUID(uuidString: id), state: state)
                        loadedRepos.append(repo)
                    }
                }
            }
            items = loadedRepos
        }
    }
    
    func save(toDefaultsKey key: String) {
        var repoIDs: [String] = []
        for repo in items {
            let repoID = repo.id.uuidString
            let dict: [String:Any] = [
                "id" : repoID,
                "name": repo.name,
                "owner": repo.owner,
                "workflow": repo.workflow,
                "state": repo.state.rawValue
            ]
            store.set(dict, forKey: repoID)
            repoIDs.append(repoID)
        }
        store.set(repoIDs, forKey: key)
    }

    func refresh() {
        scheduleRefresh(after: 0)
    }
        
    func cancelRefresh() {
        if let timer = timer {
            print("Cancelled refresh.")
            timer.invalidate()
            self.timer = nil
        }
    }
    
    func scheduleRefresh(after interval: TimeInterval) {
        cancelRefresh()
        print("Scheduled refresh for \(interval) seconds.")
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            self.doRefresh()
        }
    }
    
    func doRefresh() {
        DispatchQueue.global(qos: .background).async {
            print("Refreshing...")
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
                print("Completed Refresh")
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
