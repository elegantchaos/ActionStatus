// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Hardware
import SheetController
import SwiftUI
import SwiftUIExtensions

struct RepoCellView: View {
    @EnvironmentObject var context: ViewContext
    @EnvironmentObject var sheetController: SheetController
    @EnvironmentObject var model: Model

    let repo: Repo
    let selectable: Bool
    let namespace: Namespace.ID

    #if os(tvOS)
    let focus: FocusState<Focus?>.Binding
    #endif

    var body: some View {
        let cell = cell(for: repo)
        return cell
            .shim
            .contextMenu {
                Text("\(repo.name)")
                
                Button(action: handleEdit) {
                    Label("Settings…", systemImage: context.editButtonIcon)
                        .accessibility(identifier: "editLabel")
                }
                
                Button(action: handleGenerate) {
                    Label("Generate Workflow…", systemImage: context.generateButtonIcon)
                        .accessibility(identifier: "generateLabel")
                }
                .accessibility(identifier: "generate")
                
                Button(action: handleShowRepo) {
                    Label("Open In Github…", systemImage: context.linkIcon)
                }
                
                Button(action: handleShowWorkflow) {
                    Label("Open Workflow In Github…", systemImage: context.linkIcon)
                }

                if let url = repo.url(forDevice: Device.main.identifier) {
                    Button(action: { handleReveal(url: url) }) {
                        Label("Reveal In Finder…", systemImage: context.linkIcon)
                    }
                }

                Divider()
                
                Button(action: handleDelete) {
                    Label("Delete", systemImage: context.deleteRepoIcon)
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
     }
    
    func cell(for repo: Repo) -> some View {
        return Button(action: handleEdit) {
            HStack(alignment: .center, spacing: context.padding) {
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
        .padding(cellPadding)
        .font(context.settings.displaySize.font)
        .foregroundColor(.primary)
        #if os(tvOS)
        .buttonStyle(TestButtonStyle(repo: repo))
        .focused(focus, equals: .repo(repo.id))
        #else
        .buttonStyle(.plain)
        #endif
    }
    
    func handleShowRepo() {
        context.host.open(url: repo.githubURL(for: .repo))
    }
    
    func handleShowWorkflow() {
        context.host.open(url: repo.githubURL(for: .workflow))
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
 
    func handleReveal(url: URL) {
        url.accessSecurityScopedResource { unlockedURL in
            context.host.reveal(url: unlockedURL)
        }
    }
    
    var cellPadding: CGFloat {
        #if os(tvOS)
            return 0
        #else
            return 4
        #endif
    }
}


struct TestButtonStyle: ButtonStyle {
    @EnvironmentObject var focus: FocusThingy
    @Environment(\.isFocused) var isFocused: Bool

    let repo: Repo
    
    func makeBody(configuration: Configuration) -> some View {
        if isFocused {
            if focus.focussedRepo != repo.id {
                focus.focussedRepo = repo.id
            }
        }
        return configuration.label
            .background(isFocused ? Color.gray.opacity(focus.alpha) : Color.clear)
    }
}
