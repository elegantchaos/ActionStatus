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

    let repo: Repo
    let selectable: Bool
    
    var body: some View {
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
                Button(action: handleShowRepo) {
                    Image(systemName: viewState.linkIcon)
                }
            } else {
                Spacer()
            }
        }
        .font(viewState.displaySize.font)
        .shim.contextMenu() { makeContentMenu(for: repo) }
        .shim.onTapGesture(perform: handleEdit)
        .padding(0)
    }
    
    func makeContentMenu(for repo: Repo) -> some View {
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
        }
    }
    
    func handleShowRepo() {
        viewState.host.openGithub(with: repo, at: .repo)
    }
    
    func handleShowWorkflow() {
        viewState.host.openGithub(with: repo, at: .workflow)
    }
    
    func handleEdit() {
        if selectable {
            sheetController.show() {
                EditView(repo: repo)
            }
        }
    }
}
