// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/05/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SheetController
import SwiftUI
import SwiftUIExtensions

public struct RepoGridView: View {
    @EnvironmentObject var viewState: ViewState
    @EnvironmentObject var status: RepoState
    
    public init() {
    }
    
    public var body: some View {
        ScrollView {
            LazyVGrid(columns: viewState.repoGridColumns, spacing: 4) {
                ForEach(status.sortedRepos) { repo in
                    RepoCellView(repoID: repo.id, selectable: false)
                }
            }.padding()
        }
    }
}

struct RepoGridView_Previews: PreviewProvider {
    static var previews: some View {
        return PreviewContext().inject(into: RepoGridView())
    }
}
