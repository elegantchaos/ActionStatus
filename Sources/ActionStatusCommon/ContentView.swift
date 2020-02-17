// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct XImage: View {
    let name: String
    
    var body: some View {
        #if os(macOS)
        return Image(name)
        #else
        return Image(systemName: name)
        #endif
    }
}

struct ContentView: View {
    @ObservedObject var repos: RepoSet
    @State var selectedID: UUID? = nil
    @State var isEditing: Bool = false
    var body: some View {
            NavigationView {
                VStack(alignment: .leading) {
                    Spacer()
                    List {
                        ForEach(repos.items) { repo in
                            ZStack(alignment: .leading) {
                                NavigationLink(
                                    destination: RepoEditView(repo: self.$repos.binding(for: repo, in: \.items)),
                                    tag: repo.id,
                                    selection: self.$selectedID) {
                                        if self.isEditing {
                                            self.rowView(for: repo)
                                        } else {
                                            EmptyView()
                                        }
                                }
                                    .padding([.leading, .trailing], 10)

                                if !self.isEditing {
                                    self.rowView(for: repo)
                                }
                            }
                        }
                        .onDelete(perform: delete)
                    }
                    Spacer()
                    
                    
                    Spacer()
                    Text("Monitoring \(repos.items.count) repos.").font(.footnote)
                }
                .navigationItems(repos: repos, isEditing: self.$isEditing)
                .bindEditing(to: $isEditing)
        }
            .navigationStyle()
            .onAppear() {
                self.repos.refresh()
            }
    }
    
    func delete(at offsets: IndexSet) {
        repos.items.remove(atOffsets: offsets)
        AppDelegate.shared.saveState()
    }
    
    func rowView(for repo: Repo) -> some View {
        return HStack(alignment: .center, spacing: 20.0) {
            XImage(name: repo.badgeName)
                .foregroundColor(repo.statusColor)
            Text(repo.name)
        }
        .padding(.horizontal)
        .font(.title)
        .onTapGesture {
            self.selectedID = repo.id
        }
    }
}

extension View {
    #if os(tvOS)
    func navigationItems(repos: RepoSet, isEditing: Binding<Bool>) -> some View {
        return navigationBarHidden(false)
    }
    func navigationStyle() -> some View {
        return navigationViewStyle(StackNavigationViewStyle())
    }
    func bindEditing(to binding: Binding<Bool>) -> some View {
        return self
    }
    #elseif canImport(UIKit)
    func navigationItems(repos: RepoSet, isEditing: Binding<Bool>) -> some View {
        return navigationBarHidden(false)
        .navigationBarTitle("Action Status", displayMode: .inline)
            .navigationBarItems(leading: LeadingButtons(repos: repos), trailing: TrailingButtons(repos: repos, isEditing: isEditing))
    }
    func navigationStyle() -> some View {
        return navigationViewStyle(StackNavigationViewStyle())
    }
    func bindEditing(to binding: Binding<Bool>) -> some View {
        environment(\.editMode, .constant(binding.wrappedValue ? .active : .inactive))
    }
    #else // macOS / AppKit
    func navigationItems(repos: RepoSet, isEditing: Binding<Bool>) -> some View {
        return navigationViewStyle(DefaultNavigationViewStyle())
    }
    func navigationStyle() -> some View {
        return navigationViewStyle(DefaultNavigationViewStyle())
    }
    func bindEditing(to binding: Binding<Bool>) -> some View {
        return self
    }
    #endif
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
        Button(action: { self.repos.refresh() }) {
            XImage(name: "arrow.clockwise").font(.title)
        }
    }
}

struct AddButton: View {
    @ObservedObject var repos: RepoSet
    var body: some View {
        Button(
            action: {
            self.repos.addRepo()
            AppDelegate.shared.saveState()
        }) {
            XImage(name: "plus.circle").font(.title)
        }
    }
}


#if os(macOS)
struct LeadingButtons: View {
    @ObservedObject var repos: RepoSet
    
    var body: some View {
        AddButton(repos: repos)
        .disabled(showAdd)
//        .opacity((editMode?.wrappedValue.isEditing ?? true) ? 1.0 : 0.0)
    }
    
    var showAdd: Bool {
        return true
//        return !(editMode?.wrappedValue.isEditing ?? true)
    }
}
#else
struct LeadingButtons: View {
    @ObservedObject var repos: RepoSet
    @Environment(\.editMode) var editMode
    
    var body: some View {
        AddButton(repos: repos)
        .disabled(showAdd)
        .opacity((editMode?.wrappedValue.isEditing ?? true) ? 1.0 : 0.0)
    }
    
    var showAdd: Bool {
        return !(editMode?.wrappedValue.isEditing ?? true)
    }
}
struct TrailingButtons: View {
    @ObservedObject var repos: RepoSet
    @Binding var isEditing: Bool

    var body: some View {
        Button(action: {
            self.isEditing = !self.isEditing
        }) {
            XImage(name: isEditing ? "pencil.circle.fill" : "pencil.circle").font(.title)
        }
    }
}
#endif
