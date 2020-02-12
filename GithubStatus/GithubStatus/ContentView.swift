// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

let repos = [
    Repo("ApplicationExtensions"),
    Repo("Datastore", workflow: "Swift"),
    Repo("DatastoreViewer", workflow: "Build"),
    Repo("Logger", workflow: "tests"),
    Repo("ViewExtensions"),
]

struct ContentView: View {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
