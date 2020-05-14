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
                self.rowView(for: repoID)
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
    
    func edit(repoID: UUID) {
        viewState.showEditSheet(forRepoId: repoID)
    }
    
    func rowView(for repoID: UUID) -> some View {
        let selectable = viewState.isEditing
        let repo = model.repo(withIdentifier: repoID)!
        let view = HStack(alignment: .center, spacing: viewState.padding) {
            SystemImage(repo.badgeName)
                .foregroundColor(repo.statusColor)
            Text(repo.name)
                .allowsTightening(true)
                .truncationMode(.middle)
                .lineLimit(1)
            if selectable {
                Spacer()
                EditButton(repoID: repoID)
            }
        }
        .rowPadding()
        .padding([.leading, .trailing], viewState.padding)
        .font(viewState.repoTextSize.font)
        .contextMenu(for: repo, model: model, viewState: viewState)
        .onTapGestureShim() {
            if selectable {
                self.edit(repoID: repoID)
            }
        }
        
        return view
    }
}

fileprivate extension View {
    #if os(tvOS)
    
    // MARK: tvOS Overrides
    
    func contextMenu(for repoID: UUID) -> some View {
        return self
    }
    
    func bindEditing(to binding: Binding<Bool>) -> some View {
        return self
    }
    
    #elseif canImport(UIKit)
    
    // MARK: iOS/macOS
    
    func contextMenu(for repo: Repo, model: Model, viewState: ViewState) -> some View {
        return contextMenu {
            VStack {
                Button(action: {
                    viewState.showEditSheet(forRepoId: repo.id)
                }) {
                    Text("Edit…")
                }
                
                Button(action: { model.remove(repos: [repo.id]) }) {
                    Text("Delete")
                }
                
                Button(action: { Application.shared.openGithub(with: repo, at: .repo) }) {
                    Text("Show Repository In Github…")
                }
                
                Button(action: { Application.shared.openGithub(with: repo, at: .workflow) }) {
                    Text("Show Workflow In Github…")
                }
                
                Button(action: {
                    viewState.showComposeSheet(forRepoId: repo.id)
                }) {
                    Text("Generate Workflow…")
                }
            }
            
        }
    }
    
    func bindEditing(to binding: Binding<Bool>) -> some View {
        environment(\.editMode, .constant(binding.wrappedValue ? .active : .inactive))
    }
    
    #endif
}
