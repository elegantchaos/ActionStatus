// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

public struct RepoListView: View {
  @Environment(Engine.self) var engine
  @Environment(StatusService.self) var status
  @Environment(SettingsService.self) private var settingsService
  @AppStorage(.displaySize) var displaySize

  let namespace: Namespace.ID

  let focus: FocusState<Focus?>.Binding

  public var body: some View {
    let list = List {
      ForEach(status.sortedRepos) { repo in
        RepoCellView(
          repo: repo,
          selectable: true,
          namespace: namespace,
          isSource: settingsService.isEditing,
          focus: focus
        )
      }
      .onDelete(perform: delete)
    }
    .buttonStyle(.borderless)
    .environment(\.defaultMinListRowHeight, displaySize.rowHeight)

    #if os(macOS)
      return list
    #else
      return list.environment(\.editMode, .constant(settingsService.isEditing ? .active : .inactive))
    #endif
  }

  func delete(at offsets: IndexSet) {
    let ids = status.repoIDs(atOffets: offsets)
    Task { try? await engine.perform(RemoveReposCommand(ids: ids)) }
  }
}

//
//struct RepoListView_Previews: PreviewProvider {
//    static var previews: some View {
//        return PreviewContext().inject(into: RepoListView())
//    }
//}
