// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 06/03/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import SwiftUIExtensions
import ActionStatusCore

struct ReposView: View {
    @EnvironmentObject var model: Model
    @EnvironmentObject var viewState: ViewState

    @State var selectedID: UUID? = nil
    @State var isEditing: Bool = false
    

    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(model.itemIdentifiers, id: \.self) { repoID in
                    self.rowView(for: repoID, selectable: false)
                }
                .onDelete(perform: delete)
            }
        }.bindEditing(to: $isEditing)

        

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
                
                Button(action: { self.model.remove(repo: repo) }) {
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
