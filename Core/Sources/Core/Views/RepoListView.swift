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
    @EnvironmentObject var status: RepoState
    
    public init() {
    }
    
    public var body: some View {
        VStack {
            if viewState.settings.isEditing {
                List {
                    ForEach(status.sortedRepos) { repo in
                        RepoCellView(repo: repo, selectable: true)
                    }
                    .onDelete(perform: delete)
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: viewState.repoGridColumns, spacing: 0) {
                        ForEach(status.sortedRepos) { repo in
                            RepoCellView(repo: repo, selectable: false)
                        }
                    }.padding()
                }
            }
        }
        .environment(\.defaultMinListRowHeight, viewState.settings.displaySize.rowHeight)
        .bindEditing(to: $viewState.settings.isEditing)
    }
    
    func delete(at offsets: IndexSet) {
        let ids = status.repoIDs(atOffets: offsets)
        model.remove(reposWithIDs: ids)
        viewState.host.saveState()
    }
    
    
}

struct RepoListView_Previews: PreviewProvider {
    static var previews: some View {
        return PreviewContext().inject(into: RepoListView())
    }
}
