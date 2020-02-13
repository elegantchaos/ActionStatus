// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct ContentView: View {
    @ObservedObject var repos: RepoSet
    
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
                ForEach(repos.items) { repo in
                    HStack {
                        NavigationLink(destination: RepoEditView(repo: self.$repos.binding(for: repo, in: \.items))) {
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

            Text("Monitoring \(repos.items.count) repos.").font(.footnote)
        }.onAppear() {
            self.repos.reload()
        }
    }
}

extension ObservedObject.Wrapper {
    func binding<Item>(for item: Item, in path: KeyPath<Self, Binding<Array<Item>>>) -> Binding<Item> where Item: Equatable {
        let boundlist = self[keyPath: path]
        let index = boundlist.wrappedValue.firstIndex(of: item)!
        let binding = (self[keyPath: path])[index]
        return binding
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(repos: AppDelegate.shared.testRepos)
    }
}
