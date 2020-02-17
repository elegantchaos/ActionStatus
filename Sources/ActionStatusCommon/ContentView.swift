// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import SwiftUIExtensions

struct ContentView: View {
    @ObservedObject var repos: RepoSet
    @State var selectedID: UUID? = nil
    @State var isEditing: Bool = false
    
    var body: some View {
            NavigationView {
                VStack(alignment: .center) {
                    if repos.items.count == 0 {
                        Spacer()
                        Text("No Repos Configured").font(.title)
                        Spacer()
                        Button(action: {
                            self.isEditing = true
                            self.addRepo()
                        }) {
                            Text("Configure a repo to begin monitoring it.")
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        List {
                            ForEach(repos.items) { repo in
                                if self.isEditing {
                                    NavigationLink(
                                        destination: RepoEditView(repo: self.$repos.binding(for: repo, in: \.items)),
                                        tag: repo.id,
                                        selection: self.$selectedID) {
                                            self.rowView(for: repo, selectable: true)
                                    }
                                    .padding([.leading, .trailing], 10)
                                } else {
                                    self.rowView(for: repo, selectable: false)
                                }
                            }
                            .onDelete(perform: delete)
                        }
                    }
                    
                    Spacer()
                    
                    Text("Monitoring \(repos.items.count) repos.").font(.footnote)
                }
                .setupNavigation(editAction: { self.isEditing.toggle() }, addAction: { self.addRepo() })
                .bindEditing(to: $isEditing)
        }
            .setupNavigationStyle()
            .onAppear() {
                self.repos.refresh()
            }
    }
    
    func addRepo() {
        let newRepo = repos.addRepo()
        AppDelegate.shared.saveState()
        selectedID = newRepo.id
    }
    
    func delete(at offsets: IndexSet) {
        repos.items.remove(atOffsets: offsets)
        AppDelegate.shared.saveState()
    }
    
    func rowView(for repo: Repo, selectable: Bool) -> some View {
        return HStack(alignment: .center, spacing: 20.0) {
            SystemImage(repo.badgeName)
                .foregroundColor(repo.statusColor)
            Text(repo.name)
        }
        .padding(.horizontal)
        .font(.title)
        .onTapGestureShim() {
                if selectable {
                    self.selectedID = repo.id
                }
        }
    }
}

fileprivate extension View {
    
    #if os(tvOS)
    
    // MARK: tvOS Overrides
    
    func setupNavigation(editAction: @escaping () -> (Void), addAction: @escaping () -> (Void)) -> some View {
        return navigationBarHidden(false)
    }
    func setupNavigationStyle() -> some View {
        return navigationViewStyle(StackNavigationViewStyle())
    }
    func bindEditing(to binding: Binding<Bool>) -> some View {
        return self
    }
    
    #elseif canImport(UIKit)
    
    // MARK: iOS/tvOS
    
    func setupNavigation(editAction: @escaping () -> (Void), addAction: @escaping () -> (Void)) -> some View {
        return navigationBarHidden(false)
        .navigationBarTitle("Action Status", displayMode: .inline)
        .navigationBarItems(
            leading: AddButton(action: addAction),
            trailing: EditButton(action: editAction))
    }
    func setupNavigationStyle() -> some View {
        return navigationViewStyle(StackNavigationViewStyle())
    }
    func bindEditing(to binding: Binding<Bool>) -> some View {
        environment(\.editMode, .constant(binding.wrappedValue ? .active : .inactive))
    }
    
    #else // MARK: AppKit Overrides
    func setupNavigation(editAction: @escaping () -> (Void), addAction: @escaping () -> (Void)) -> some View {
        return navigationViewStyle(DefaultNavigationViewStyle())
    }
    func setupNavigationStyle() -> some View {
        return navigationViewStyle(DefaultNavigationViewStyle())
    }
    func bindEditing(to binding: Binding<Bool>) -> some View {
        return self
    }
    #endif
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(repos: AppDelegate.shared.testRepos)
    }
}

#if canImport(UIKit)
struct AddButton: View {
    @Environment(\.editMode) var editMode
    var action: () -> (Void)
    
    var body: some View {
        Button(action: self.action) {
            SystemImage("plus.circle").font(.title)
        }
        .disabled(showAdd)
        .opacity((editMode?.wrappedValue.isEditing ?? true) ? 1.0 : 0.0)
    }
    
    var showAdd: Bool {
        return !(editMode?.wrappedValue.isEditing ?? true)
    }
}

struct EditButton: View {
    @Environment(\.editMode) var editMode
    var action: () -> (Void)

    var body: some View {
        Button(action: self.action) {
            SystemImage(editMode?.wrappedValue.isEditing ?? true ? "pencil.circle.fill" : "pencil.circle").font(.title)
        }
    }
}
#endif
