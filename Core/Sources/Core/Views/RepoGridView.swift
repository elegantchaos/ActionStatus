// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/05/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SheetController
import SwiftUI
import SwiftUIExtensions

public struct RepoGridView: View {
    @EnvironmentObject var context: ViewContext
    @EnvironmentObject var status: RepoState
    
    let namespace: Namespace.ID
    
    public var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: context.repoGridColumns, spacing: 4) {
                ForEach(status.sortedRepos) { repo in
                    RepoCellView(repo: repo, selectable: false, namespace: namespace)
                }
            }
        }
        .padding()
    }
}

//struct RepoGridView_Previews: PreviewProvider {
//    static var previews: some View {
//        return PreviewContext().inject(into: RepoGridView())
//    }
//}
