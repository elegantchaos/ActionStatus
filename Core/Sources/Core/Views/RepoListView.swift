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
    
    public init() {
    }
    
    public var body: some View {
        VStack {
            if viewState.isEditing {
                List {
                    ForEach(model.itemIdentifiers, id: \.self) { repoID in
                        RepoCellView(repoID: repoID, selectable: true)
                    }
                    .onDelete(perform: delete)
                }
            } else {
                let columns = [
                      GridItem(.adaptive(minimum: 256))
                  ]

                LazyVGrid(columns: columns) {
                    ForEach(model.itemIdentifiers, id: \.self) { repoID in
                        RepoCellView(repoID: repoID, selectable: false)
                    }
                }.padding()
            }
        }
        .environment(\.defaultMinListRowHeight, viewState.displaySize.rowHeight)
        .bindEditing(to: $viewState.isEditing)
    }
    
    func delete(at offsets: IndexSet) {
        model.remove(atOffsets: offsets)
        viewState.host.saveState()
    }
    
    
}

struct RepoListView_Previews: PreviewProvider {
    static var previews: some View {
        return PreviewContext().inject(into: RepoListView())
    }
}

struct RepoCellView: View {
    @EnvironmentObject var viewState: ViewState
    @EnvironmentObject var sheetController: SheetController
    @EnvironmentObject var model: Model

    let repoID: UUID
    let selectable: Bool
    
    var body: some View {
        let repo = model.repo(withIdentifier: repoID)!
        return HStack(alignment: .center, spacing: viewState.padding) {
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
                EditButton(repoID: repo.id)
            } else {
                Spacer()
            }
        }
        .font(viewState.displaySize.font)
        .shim.contextMenu() { makeContentMenu(for: repo) }
        .shim.onTapGesture() { if selectable { self.edit(repoID: repo.id) } }
        .padding(0)
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
    
    func edit(repoID: UUID) {
        sheetController.show() {
            EditView(repoID: repoID)
        }
    }
}
