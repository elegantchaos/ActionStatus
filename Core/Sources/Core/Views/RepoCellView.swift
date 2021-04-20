// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SheetController
import SwiftUI
import SwiftUIExtensions

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
                EditButton(repo: repo)
                LinkButton(url: repo.githubURL(for: .repo))
            } else {
                Spacer()
            }
        }
        .font(viewState.settings.displaySize.font)
        .shim.contextMenu() { makeContextMenu(for: repo) }
        .shim.onTapGesture(perform: handleEdit)
        .padding(0)
    }
    
    func makeContextMenu(for repo: Repo) -> some View {
        VStack {
            Button(action: {
                self.sheetController.show() {
                    EditView(repo: repo)
                }
            }) {
                Text("Edit…")
            }
            
            Button(action: { self.model.remove(reposWithIDs: [repo.id]) }) {
                Text("Delete")
            }
            
            Button(action: handleShowRepo) {
                Text("Show Repository In Github…")
            }
            
            Button(action: handleShowWorkflow) {
                Text("Show Workflow In Github…")
            }
            
            Button(action: {
                self.sheetController.show() {
                    GenerateView(repoID: repo.id)
                }
            }) {
                Text("Generate Workflow…").accessibility(identifier: "generateLabel")
            }.accessibility(identifier: "generate")
            
            #if DEBUG
            Button(action: handleToggleState) {
                Text("DEBUG: Advance State")
            }
            #endif
        }
    }
    
    func handleShowRepo() {
        if let repo = model.repo(withIdentifier: repoID) {
            viewState.host.open(url: repo.githubURL(for: .repo))
        }
    }
    
    func handleShowWorkflow() {
        if let repo = model.repo(withIdentifier: repoID) {
            viewState.host.open(url: repo.githubURL(for: .workflow))
        }
    }
    
    func handleEdit() {
        if selectable, let repo = model.repo(withIdentifier: repoID) {
            sheetController.show() {
                EditView(repo: repo)
            }
        }
    }
    
    func handleToggleState() {
        if let repo = model.repo(withIdentifier: repoID), let newState = Repo.State(rawValue: (repo.state.rawValue + 1) % UInt(Repo.State.allCases.count)) {
            model.update(repoWithID: repoID, state: newState)
        }
    }
}
