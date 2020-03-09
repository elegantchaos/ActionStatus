// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ActionStatusCore
import SwiftUI
import SwiftUIExtensions
import BindingsExtensions

struct ContentView: View {
    
    @EnvironmentObject var model: Model
    @EnvironmentObject var viewState: ViewState
    @State var isEditing: Bool = false
    @State var selectedID: UUID? = nil

    var body: some View {
            NavigationView {
                VStack(alignment: .center) {
                    if model.itemIdentifiers.count == 0 {
                        NoReposView(action: {
                            self.isEditing = true
                            self.addRepo()
                        })
                    }

                    VStack(alignment: .leading) {
                        List {
                            ForEach(model.itemIdentifiers, id: \.self) { repoID in
                                self.rowView(for: repoID, selectable: false)
                            }
                            .onDelete(perform: delete)
                        }
                    }.bindEditing(to: $isEditing)

                    Spacer()
                    FooterView()
                }
                .setupNavigation(editAction: { self.isEditing.toggle() }, addAction: { self.addRepo() })
                .sheet(isPresented: $viewState.hasSheet) { self.sheetView() }
        }
            .setupNavigationStyle()
            .onAppear(perform: onAppear)
    }
    
    func onAppear()  {
        #if !os(tvOS)
        UITableView.appearance().separatorStyle = .none
        #endif
        
        self.model.refresh()
    }
    
    func sheetView() -> some View {
        switch viewState.sheetType {
            case .save:
            #if !os(tvOS)
                return AnyView(DocumentPickerViewController(picker: Application.shared.pickerForSavingWorkflow()))
            #endif
            
            case .compose:
                if let id = viewState.composingID {
                    return AnyView(GenerateView(repoID: id, isPresented: self.$viewState.hasSheet))
                }
        }
        
        return AnyView(EmptyView())
    }
    
     
    func addRepo() {
        let newRepo = model.addRepo()
        Application.shared.saveState()
        selectedID = newRepo.id
    }
    
    
    func delete(at offsets: IndexSet) {
    //        model.items.remove(atOffsets: offsets)
            Application.shared.saveState()
        }

    func rowView(for repoID: UUID, selectable: Bool) -> some View {
        if self.isEditing {
            return AnyView(NavigationLink(
                destination: EditView(repoID: repoID),
                tag: repoID,
                selection: self.$selectedID) {
                    self.basicRowView(for: repoID, selectable: true)
            }
            .padding([.leading, .trailing], 10))
        } else {
            return AnyView(self.basicRowView(for: repoID, selectable: false))
        }
    }
    
    func basicRowView(for repoID: UUID, selectable: Bool) -> some View {
        let repo = model.repo(withIdentifier: repoID)!
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
                    destination: EditView(repoID: repoID),
                    tag: repoID,
                    selection: self.$selectedID) {
                        Text("Edit…")
                }
                
                Button(action: { self.model.remove(repos: [repoID]) }) {
                    Text("Delete")
                }
                
                Button(action: { Application.shared.openGithub(with: repo, at: .repo) }) {
                    Text("Show Repository In Github…")
                }
                
                Button(action: { Application.shared.openGithub(with: repo, at: .workflow) }) {
                    Text("Show Workflow In Github…")
                }
                
                Button(action: {
                    self.viewState.showComposeSheet(forRepoId: repo.id)
                }) {
                    Text("Generate Workflow…")
                }
            }
        }
        #endif
    }

}
