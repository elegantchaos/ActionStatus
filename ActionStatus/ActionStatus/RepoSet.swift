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
