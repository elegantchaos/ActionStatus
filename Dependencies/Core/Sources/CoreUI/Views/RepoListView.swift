// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Runtime
import SwiftUI

/// List presentation of monitored repositories.
public struct RepoListView: View {
  @Environment(ActionStatusCommander.self) var commander
  @Environment(StatusService.self) var status
  @Environment(SettingsService.self) private var settingsService
  @AppStorage(.displaySize) var displaySize

  let context: RepoContainerContext

  /// Creates a repository list view.
  public init(context: RepoContainerContext) {
    self.context = context
  }

  public var body: some View {
    let list = List {
      ForEach(status.sortedRepos) { repo in
        RepoCellView(
          repo: repo,
          context: context,
          selectable: true,
          isSource: settingsService.isEditing,
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
    let ids = status.repoIDs(atOffsets: offsets)
    Task { try? await commander.perform(RemoveReposCommand(ids: ids)) }
  }
}


private struct RepoListPreviewHost: View {
  @Namespace private var namespace
  @FocusState private var focus: Focus?

  var body: some View {
    RepoListView(context: RepoContainerContext(namespace: namespace, runtime: .shared, focus: $focus))
  }
}

#if !VALIDATING
  #Preview("Repo List", traits: .modifier(ActionStatusPreviews.Editing())) {
    RepoListPreviewHost()
  }
#endif
