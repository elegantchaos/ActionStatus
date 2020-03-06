// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ActionStatusCore
import SwiftUI
import SwiftUIExtensions
import BindingsExtensions

struct ContentView: View {
    
    @ObservedObject var updater: Updater
    @ObservedObject var repos: Model
    @EnvironmentObject var viewState: ViewState

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
                                        destination: EditView(repo: self.$repos.binding(for: repo, in: \.items)),
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
                    
                    VStack(spacing: 10) {
                        Text(statusText).statusStyle()
                        if hasUpdate {
                            SparkleView(updater: updater)
                        }
                        if showProgress {
                            GeometryReader { geometryReader in
                                SparkleProgressView(updater: self.updater).frame(width: geometryReader.size.width * 0.25)
                            }
                        }
                    }.padding()
                }
                .setupNavigation(editAction: { self.isEditing.toggle() }, addAction: { self.addRepo() })
                .bindEditing(to: $isEditing)
                .sheet(isPresented: $viewState.hasAlert) { self.sheetView() }
        }
            .setupNavigationStyle()
            .onAppear(perform: onAppear)
    }
    
    var hasUpdate: Bool {
        return updater.hasUpdate
    }
    
    var showProgress: Bool {
        return (updater.progress > 0.0) && (updater.progress < 1.0)
    }
    
    var statusText: String {
         if updater.status.isEmpty {
             return "Monitoring \(repos.items.count) repos."
         } else {
             return updater.status
         }
     }

    func onAppear()  {
        #if !os(tvOS)
        UITableView.appearance().separatorStyle = .none
        #endif
        
        self.repos.refresh()
    }
    
    func sheetView() -> some View {
        if viewState.isSaving {
            #if !os(tvOS)
                return AnyView(DocumentPickerViewController(picker: Application.shared.pickerForSavingWorkflow()))
            #endif
        } else if let id = viewState.composingID, let repo = self.repos.repo(withIdentifier: id) {
            let binding = self.$repos.binding(for: repo, in: \.items)
            return AnyView(ComposeView(repo: binding, isPresented: self.$viewState.hasAlert))
        }

        return AnyView(EmptyView())
    }
    
     
    func addRepo() {
        let newRepo = repos.addRepo()
        Application.shared.saveState()
        selectedID = newRepo.id
    }
    
    func delete(at offsets: IndexSet) {
        repos.items.remove(atOffsets: offsets)
        Application.shared.saveState()
    }
    
    func rowView(for repo: Repo, selectable: Bool) -> some View {
        let view = HStack(alignment: .center, spacing: 20.0) {
            SystemImage(repo.badgeName)
                .foregroundColor(repo.statusColor)
            Text(repo.name)
                .allowsTightening(true)
                .truncationMode(.middle)
                .lineLimit(1)
        }
        .rowPadding()
        .font(.title)
        .onTapGestureShim() {
            if selectable {
                self.selectedID = repo.id
            }
        }
        
        #if os(tvOS)
        return view
        #else
        return view.contextMenu() {
            VStack {
                NavigationLink(
                    destination: EditView(repo: self.$repos.binding(for: repo, in: \.items)),
                    tag: repo.id,
                    selection: self.$selectedID) {
                        Text("Edit…")
                }
                
                Button(action: { self.repos.remove(repo: repo) }) {
                    Text("Delete")
                }
                
                Button(action: { Application.shared.openGithub(with: repo, at: .repo) }) {
                    Text("Show Repository In Github…")
                }
                
                Button(action: { Application.shared.openGithub(with: repo, at: .workflow) }) {
                    Text("Show Workflow In Github…")
                }
                
                Button(action: {
                    self.viewState.composingID = repo.id
                    self.viewState.isSaving = false
                    self.viewState.hasAlert = true
                }) {
                    Text("Generate Workflow…")
                }
            }
        }
        #endif
    }
}

internal extension View {
    func statusStyle() -> some View {
        return font(.footnote)
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
    
    func rowPadding() -> some View {
        return self.padding(.horizontal, 80.0) // TODO: remove this special case
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

    func rowPadding() -> some View {
//        return self.padding(.horizontal)
        return self
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
        ContentView(updater: Updater(), repos: Application.shared.testRepos)
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
            SystemImage(editMode?.wrappedValue.isEditing ?? true ? "hammer.fill" : "hammer").font(.title)
        }
    }
}
#endif
