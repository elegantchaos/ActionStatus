// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct ContentView: View {
    @State private var showSettings = false
    @Binding var repos: RepoSet
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Button(action: { self.repos.reload() }) {
                    Image(systemName: "arrow.clockwise").font(.title)
                }
                Spacer()
                Text("Action Status").font(.title)
                Spacer()
                    
                Button(action: { self.showSettings = true} ) {
                    Image(systemName: "gear").font(.title)
                }.popover(isPresented: $showSettings) {
                    SettingsView(repos: self.$repos)
                }
            }
            .padding(.horizontal)

            Spacer()
            
            VStack {
                ForEach(repos.repos, id: \.self) { repo in
                    HStack {
                        Text(repo.name)
                        Image(uiImage: repo.badge())
                    }
                        .accentColor(Color.green)
                        .padding([.leading, .trailing], 10)

                }
            }
            
            Spacer()
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(repos: AppDelegate.shared.$testRepos)
    }
}
