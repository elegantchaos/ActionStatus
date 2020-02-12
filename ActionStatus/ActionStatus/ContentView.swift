// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct ContentView: View {
    @Binding var repos: RepoSet
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Button(action: { self.repos.addRepo() } ) {
                    Image(systemName: "plus.circle").font(.title)
                }

                Spacer()

                Text("Action Status").font(.title)

                Spacer()
                    
                Button(action: { self.repos.reload() }) {
                    Image(systemName: "arrow.clockwise").font(.title)
                }
            }
            .padding(.horizontal)

            Spacer()
            
            NavigationView {
            VStack {
                Text("\(repos.repos.count)")
                ForEach(repos.repos, id: \.id) { repo in
                    HStack {
                        NavigationLink(destination: RepoEditView(repo: repo)) {
                            Text(repo.name)
                        }
                        Image(systemName: repo.badgeName)
                            .foregroundColor(repo.statusColor)
                    }
                        .font(.title)
                        .padding([.leading, .trailing], 10)

                }
            }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            
            Spacer()
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(repos: AppDelegate.shared.$testRepos)
    }
}
