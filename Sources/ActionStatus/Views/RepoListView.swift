// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import SwiftUIExtensions
import ActionStatusCore

struct RepoListView: View {
    @EnvironmentObject var model: Model
    @EnvironmentObject var viewState: ViewState

    var body: some View {
            List {
                ForEach(model.itemIdentifiers, id: \.self) { repoID in
                    self.rowView(for: repoID, selectable: false)
                }
                .onDelete(perform: delete)
            }
            .environment(\.defaultMinListRowHeight, viewState.repoTextSize.rowHeight)
            .bindEditing(to: $viewState.isEditing)
    }

    func delete(at offsets: IndexSet) {
        model.remove(atOffsets: offsets)
        Application.shared.saveState()
    }

    func rowView(for repoID: UUID, selectable: Bool) -> some View {
        if viewState.isEditing {
            return AnyView(NavigationLink(
                destination: EditView(repoID: repoID),
                tag: repoID,
                selection: $viewState.selectedID) {
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
        .font(viewState.repoTextSize.font)
        .onTapGestureShim() {
            if selectable {
                self.viewState.selectedID = repo.id
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
                    selection: $viewState.selectedID) {
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

fileprivate extension View {
    #if os(tvOS)
    
    // MARK: tvOS Overrides
    
    func bindEditing(to binding: Binding<Bool>) -> some View {
        return self
    }
    
    #elseif canImport(UIKit)
    
    // MARK: iOS/tvOS
    
    func bindEditing(to binding: Binding<Bool>) -> some View {
        environment(\.editMode, .constant(binding.wrappedValue ? .active : .inactive))
    }

    #endif
}
