// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct ContentView: View {
    @ObservedObject var repos: RepoSet
    
    var body: some View {
            NavigationView {
                VStack {
                    Spacer()
                    List {
                        ForEach(repos.items) { repo in
                            NavigationLink(destination: RepoEditView(repo: self.$repos.binding(for: repo, in: \.items))) {
                                HStack(alignment: .center, spacing: 20.0) {
                                    Image(systemName: repo.badgeName)
                                        .foregroundColor(repo.statusColor)
                                    Text(repo.name)
                                }
                                .padding(.horizontal)
                            }
                            .font(.title)
                            .padding([.leading, .trailing], 10)
                            
                        }
                    }
                    Spacer()
                    Text("Monitoring \(repos.items.count) repos.").font(.footnote)
                }
                    
                .navigationBarHidden(false)
                .navigationBarTitle("Action Status", displayMode: .inline)
                .navigationBarItems(leading: AddButton(repos: self.repos), trailing: ReloadButton(repos: self.repos)
                )

        }.onAppear() {
            self.repos.reload()
        }
            .navigationViewStyle(StackNavigationViewStyle())
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

struct ReloadButton: View {
    @ObservedObject var repos: RepoSet
    var body: some View {
        Button(action: { self.repos.reload() }) {
            Image(systemName: "arrow.clockwise").font(.title)
        }
    }
}

struct AddButton: View {
    @ObservedObject var repos: RepoSet
    var body: some View {
        Button(action: { self.repos.addRepo() } ) { Image(systemName: "plus.circle").font(.title) }
    }
}
