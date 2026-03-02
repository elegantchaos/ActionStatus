// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

public struct RepoListView: View {
  @Environment(Model.self) var model
  @Environment(RepoState.self) var status
  @Environment(SettingsService.self) private var settingsService
  @AppStorage(.displaySize) var displaySize
  
  let namespace: Namespace.ID

  #if os(tvOS)
    let focus: FocusState<Focus?>.Binding
  #endif

  public var body: some View {
    let list = List {
      ForEach(status.sortedRepos) { repo in
        #if os(tvOS)
          RepoCellView(repo: repo, selectable: true, namespace: namespace, focus: focus)
        #else
          RepoCellView(repo: repo, selectable: true, namespace: namespace)
        #endif
      }
      .onDelete(perform: delete)
    }
    .environment(\.defaultMinListRowHeight, displaySize.rowHeight)

    #if os(macOS)
      return list
    #else
      return list.environment(\.editMode, .constant(settingsService.settings.isEditing ? .active : .inactive))
    #endif
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
