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
                VStack(alignment: .leading) {
                    Spacer()
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
                    Spacer()
                    
                    
                    Spacer()
                    Text("Monitoring \(repos.items.count) repos.").font(.footnote)
                }
                .setupNavigation(repos: repos, isEditing: self.$isEditing, selectedID: self.$selectedID)
                .bindEditing(to: $isEditing)
        }
            .setupNavigationStyle()
            .onAppear() {
                self.repos.refresh()
            }
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
        .setupTapHandler() {
                if selectable {
                    self.selectedID = repo.id
                }
        }
    }
}

fileprivate extension View {
    
    #if os(tvOS)
    
    // MARK: tvOS Overrides
    
    func setupNavigation(repos: RepoSet, isEditing: Binding<Bool>, selectedID: Binding<UUID?>) -> some View {
        return navigationBarHidden(false)
    }
    func setupNavigationStyle() -> some View {
        return navigationViewStyle(StackNavigationViewStyle())
    }
    func bindEditing(to binding: Binding<Bool>) -> some View {
        return self
    }
    func setupTapHandler(perform action: @escaping () -> Void) -> some View {
        return self
    }
    
    #elseif canImport(UIKit)
    
    // MARK: iOS/tvOS
    
    func setupNavigation(repos: RepoSet, isEditing: Binding<Bool>, selectedID: Binding<UUID?>) -> some View {
        return navigationBarHidden(false)
        .navigationBarTitle("Action Status", displayMode: .inline)
        .navigationBarItems(leading: LeadingButtons(repos: repos, selectedID: selectedID), trailing: TrailingButtons(repos: repos, isEditing: isEditing))
    }
    func setupNavigationStyle() -> some View {
        return navigationViewStyle(StackNavigationViewStyle())
    }
    func bindEditing(to binding: Binding<Bool>) -> some View {
        environment(\.editMode, .constant(binding.wrappedValue ? .active : .inactive))
    }
    func setupTapHandler(perform action: @escaping () -> Void) -> some View {
        return onTapGesture(perform: action)
    }
    
    #else // MARK: AppKit Overrides
    func setupNavigation(repos: RepoSet, isEditing: Binding<Bool>, selectedID: Binding<UUID?>) -> some View {
        return navigationViewStyle(DefaultNavigationViewStyle())
    }
    func setupNavigationStyle() -> some View {
        return navigationViewStyle(DefaultNavigationViewStyle())
    }
    func bindEditing(to binding: Binding<Bool>) -> some View {
        return self
    }
    func setupTapHandler(perform action: @escaping () -> Void) -> some View {
        return self
    }
    #endif
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(repos: AppDelegate.shared.testRepos)
    }
}

struct AddButton: View {
    @ObservedObject var repos: RepoSet
    @Binding var selectedID: UUID?
    var body: some View {
        Button(
            action: {
            let newRepo = self.repos.addRepo()
            AppDelegate.shared.saveState()
            self.selectedID = newRepo.id
        }) {
            SystemImage("plus.circle").font(.title)
        }
    }
}



#if canImport(UIKit)
struct LeadingButtons: View {
    @ObservedObject var repos: RepoSet
    @Environment(\.editMode) var editMode
    @Binding var selectedID: UUID?

    var body: some View {
        AddButton(repos: repos, selectedID: self.$selectedID)
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
            SystemImage(isEditing ? "pencil.circle.fill" : "pencil.circle").font(.title)
        }
    }
}
#else // macOS / AppKit
struct LeadingButtons: View {
    @ObservedObject var repos: RepoSet
    @Binding var addedID: UUID?

    var body: some View {
        AddButton(repos: repos, selectedID: self.$addedID)
    }
}
#endif
