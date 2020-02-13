// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 12/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

class RepoSet: ObservableObject {
    @Published var items: [Repo]
    
    init(_ repos: [Repo]) {
        self.items = repos
    }
    
    func reload() {
        for repo in items {
            repo.reload()
        }
    }

    func addRepo() {
        let repo = Repo("Untitled", owner: "Untitled", workflow: "Untitled", testState: .unknown)
        items.append(repo)
    }
}
