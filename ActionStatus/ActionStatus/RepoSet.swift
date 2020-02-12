// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 12/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class RepoSet {
    var repos: [Repo]
    
    init(_ repos: [Repo]) {
        self.repos = repos
    }
    
    func reload() {
        var updatedRepos: [Repo] = []
        for repo in repos {
            var updated = repo
            updated.reload()
            updatedRepos.append(updated)
        }
        repos = updatedRepos
    }

}
