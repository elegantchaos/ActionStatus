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
    @EnvironmentObject var status: Status
    
    public init() {
    }
    
    public var body: some View {
        VStack {
            if viewState.isEditing {
                List {
                    ForEach(status.sortedRepos) { repo in
                        RepoCellView(repo: repo, selectable: true)
                    }
                    .onDelete(perform: delete)
                }
            } else {
                let columns = [
                      GridItem(.adaptive(minimum: 256))
                  ]

                LazyVGrid(columns: columns) {
                    ForEach(status.sortedRepos) { repo in
                        RepoCellView(repo: repo, selectable: false)
                    }
                }.padding()
            }
        }
        .environment(\.defaultMinListRowHeight, viewState.displaySize.rowHeight)
        .bindEditing(to: $viewState.isEditing)
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
