// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct SettingsView: View {
    @Binding var repos: RepoSet
    
    var body: some View {
        VStack {
            Text("Repos to monitor:")
            ForEach(repos.items, id: \.id) { repo in
                HStack {
                    Image(systemName: "minus.circle")
                    RepoEditView(repo: repo)
                }
            }
            Button(action: { self.repos.addRepo() }) {
                Image(systemName: "plus.circle")
            }
        }.padding(.horizontal)

    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(repos: AppDelegate.shared.$testRepos)
    }
}
