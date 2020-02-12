// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct ContentView: View {
    let repos: [Repo]
    
    var body: some View {
        VStack(alignment: .center) {
            ForEach(repos, id: \.self) { repo in
                HStack {
                    Text(repo.name)
                    Image(uiImage: repo.badge())
                }

            }
        }
    }
    
}

let testRepos = [
    Repo("ApplicationExtensions", testState: .failing),
    Repo("Datastore", workflow: "Swift", testState: .passing),
    Repo("DatastoreViewer", workflow: "Build", testState: .failing),
    Repo("Logger", workflow: "tests", testState: .unknown),
    Repo("ViewExtensions", testState: .passing),
]

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(repos: testRepos)
    }
}
