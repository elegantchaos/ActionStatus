// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SheetController
import SwiftUI
import SwiftUIExtensions

public struct RepoListView: View {
    @EnvironmentObject var model: Model
    @EnvironmentObject var viewState: ViewState
    @EnvironmentObject var sheetController: SheetController
    
    public init() {
    }
    
    public var body: some View {
        List {
            ForEach(model.itemIdentifiers, id: \.self) { repoID in
                self.rowView(for: repoID)
            }
            .onDelete(perform: delete)
        }
        .environment(\.defaultMinListRowHeight, viewState.displaySize.rowHeight)
        .bindEditing(to: $viewState.isEditing)
    }
    
    func delete(at offsets: IndexSet) {
        model.remove(atOffsets: offsets)
        viewState.host.saveState()
    }
    
    func edit(repoID: UUID) {
        sheetController.show() {
            EditView(repoID: repoID)
        }
    }
    
    func rowView(for repoID: UUID) -> some View {
        let selectable = viewState.isEditing
        let repo = model.repo(withIdentifier: repoID)!
        let view = HStack(alignment: .center, spacing: viewState.padding) {
            if !selectable {
                SystemImage(repo.badgeName)
                    .foregroundColor(repo.statusColor)
            }
            Text(repo.name)
                .allowsTightening(true)
                .truncationMode(.middle)
                .lineLimit(1)
            if selectable {
                Spacer()
                EditButton(repoID: repoID)
            }
        }
        .font(viewState.displaySize.font)
        .shim.contextMenu() { makeContentMenu(for: repo) }
        .shim.onTapGesture() { if selectable { self.edit(repoID: repoID) } }
        
        return view.padding(0)
    }
    
    func makeContentMenu(for repo: Repo) -> some View {
        VStack {
            Button(action: {
                self.sheetController.show() {
                    EditView(repoID: repo.id)
                }
            }) {
                Text("Edit…")
            }
            
            Button(action: { self.model.remove(repos: [repo.id]) }) {
                Text("Delete")
            }
            
            Button(action: { viewState.host.openGithub(with: repo, at: .repo) }) {
                Text("Show Repository In Github…")
            }
            
            Button(action: { viewState.host.openGithub(with: repo, at: .workflow) }) {
                Text("Show Workflow In Github…")
            }
            
            Button(action: {
                self.sheetController.show() {
                    GenerateView(repoID: repo.id)
                }
            }) {
                Text("Generate Workflow…").accessibility(identifier: "generateLabel")
            }.accessibility(identifier: "generate")
        }
    }
}

struct RepoListView_Previews: PreviewProvider {
    static var previews: some View {
        return PreviewContext().inject(into: RepoListView())
    }
}
