// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SheetController
import SwiftUI
import SwiftUIExtensions

public struct RepoListView: View {
  @EnvironmentObject var model: Model
  @EnvironmentObject var context: ViewContext
  @EnvironmentObject var status: RepoState

  let namespace: Namespace.ID

  #if os(tvOS)
    let focus: FocusState<Focus?>.Binding
  #endif

  public var body: some View {
    List {
      ForEach(status.sortedRepos) { repo in
        #if os(tvOS)
          RepoCellView(repo: repo, selectable: true, namespace: namespace, focus: focus)
        #else
          RepoCellView(repo: repo, selectable: true, namespace: namespace)
        #endif
      }
      .onDelete(perform: delete)
    }
    .environment(\.defaultMinListRowHeight, context.settings.displaySize.rowHeight)
    .bindEditing(to: $context.settings.isEditing)
  }

  func delete(at offsets: IndexSet) {
    let ids = status.repoIDs(atOffets: offsets)
    model.remove(reposWithIDs: ids)
  }
}

//
//struct RepoListView_Previews: PreviewProvider {
//    static var previews: some View {
//        return PreviewContext().inject(into: RepoListView())
//    }
//}
