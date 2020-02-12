// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 12/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

class RepoSet {
    @Published var repos: [Repo]
    
    init(_ repos: [Repo]) {
        self.repos = repos
    }
    
    func reload() {
        for repo in repos {
            repo.reload()
        }
    }

    func addRepo() {
        let repo = Repo("Untitled", owner: "Untitled", workflow: "Untitled", testState: .unknown)
        repos.append(repo)
    }
}
