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
                        NavigationLink(destination: RepoEditView(repo: self.binding(for: repo))) {
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
 
    func binding(for repo: Repo) -> Binding<Repo> {
        let index = repos.items.firstIndex(of: repo)!
        let binding = $repos.items[index]
        print(type(of: $repos.items))
        return binding
    }
}

func binding<Container, Item>(for item: Item, in container: Binding<Container>, path: KeyPath<Binding<Container>, Binding<Array<Item>>>) -> Binding<Item> where Item: Equatable {
    let boundlist = container[keyPath: path]
    let index = boundlist.wrappedValue.firstIndex(of: item)!
    let item = (container[keyPath:path])[index]
    return item
}

//func binding<Container, List, Item>(for item: Item, in container: Binding<Container>, path: KeyPath<Binding<Container>, Binding<List>>) -> Binding<Item> where List: Array, List.Element == Item, Item: Equatable {
////    let index = container.wrappedValue[keyPath: path].firstIndex(of: item)!
//    let boundlist = container[keyPath: path]
//    let index = boundlist.wrappedValue.firstIndex(of: item)!
//    let item = (container[keyPath:path])[index]
//    return item
//}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(repos: AppDelegate.shared.testRepos)
    }
}
