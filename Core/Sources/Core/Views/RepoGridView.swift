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

#if os(tvOS)
let focus: FocusState<Focus?>.Binding
#endif

    public var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: context.repoGridColumns, spacing: 0) {
                ForEach(status.sortedRepos) { repo in
                    #if os(tvOS)
                        RepoCellView(repo: repo, selectable: false, namespace: namespace, focus: focus)
                    #else
                    RepoCellView(repo: repo, selectable: false, namespace: namespace)
                    #endif
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
