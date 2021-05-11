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
    let namespace: Namespace.ID

    var body: some View {
        cellWithMenu(for: repo)
    }
    
    func cell(for repo: Repo) -> some View {
        return Button(action: handleEdit) {
            HStack(alignment: .center, spacing: viewState.padding) {
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
                    GenerateButton(repo: repo)
                    LinkButton(url: repo.githubURL(for: .repo))
                } else {
                    Spacer()
                }
            }
            .matchedGeometryEffect(id: repo.id, in: namespace)
        }
        .padding(0)
        .font(viewState.settings.displaySize.font)
        .foregroundColor(.black)
        .buttonStyle(PlainButtonStyle())
    }
    
    func cellWithMenu(for repo: Repo) -> some View {
        return cell(for: repo)
            .contextMenu(
                ContextMenu {
                    Text("\(repo.name)")
                    
                    Button(action: handleEdit) {
                        Label("Settings…", systemImage: viewState.editButtonIcon)
                            .accessibility(identifier: "editLabel")
                    }
                    
                    Button(action: handleGenerate) {
                        Label("Workflow…", systemImage: viewState.generateButtonIcon)
                            .accessibility(identifier: "generateLabel")
                    }
                    .accessibility(identifier: "generate")
                    
                    Button(action: handleShowRepo) {
                        Label("Open In Github…", systemImage: viewState.linkIcon)
                    }
                    
                    Button(action: handleShowWorkflow) {
                        Label("Open Workflow In Github…", systemImage: viewState.linkIcon)
                    }
                    
                    Divider()
                    
                    Button(action: handleDelete) {
                        Label("Delete", systemImage: viewState.deleteRepoIcon)
                    }
                    #if DEBUG
                    
                    if !ProcessInfo.processInfo.environment.isTestingUI {
                        Divider()
                        Button(action: handleToggleState) {
                            Text("DEBUG: Advance State")
                        }
                    }
                    #endif
                }
            )
    }
    
    func handleShowRepo() {
        viewState.host.open(url: repo.githubURL(for: .repo))
    }
    
    func handleShowWorkflow() {
        viewState.host.open(url: repo.githubURL(for: .workflow))
    }
    
    func handleEdit() {
        sheetController.show() {
            EditView(repo: repo)
        }
    }
    
    func handleGenerate() {
        sheetController.show() {
            GenerateView(repoID: repo.id)
        }
    }
    
    func handleDelete() {
        model.remove(reposWithIDs: [repo.id])
    }
    
    func handleToggleState() {
        if let newState = Repo.State(rawValue: (repo.state.rawValue + 1) % UInt(Repo.State.allCases.count)) {
            model.update(repoWithID: repo.id, state: newState)
        }
    }
    
}
