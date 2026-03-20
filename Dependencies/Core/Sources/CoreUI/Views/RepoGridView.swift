// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/05/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Runtime
import SwiftUI

public struct RepoContainerContext {
  let namespace: Namespace.ID

  /// Runtime metadata. Injectable for testing purposes.
  let runtime: Runtime

  let focus: FocusState<Focus?>.Binding

  /// Creates a context for a repository container view.
  public init(namespace: Namespace.ID, runtime: Runtime = .shared, focus: FocusState<Focus?>.Binding) {
    self.namespace = namespace
    self.runtime = runtime
    self.focus = focus
  }
}

/// Grid presentation of monitored repositories.
public struct RepoGridView: View {
  @Environment(StatusService.self) var status
  @Environment(SettingsService.self) var settings
  @AppStorage(.displaySize) var displaySize

  let context: RepoContainerContext

  /// Creates a repository grid view.
  public init(context: RepoContainerContext) {
    self.context = context
  }

  public var body: some View {
    ScrollView(.vertical) {
      LazyVGrid(columns: repoGridColumns, spacing: 0) {
        ForEach(status.sortedRepos) { repo in
          RepoCellView(
            repo: repo,
            context: context,
            selectable: false,
            isSource: !settings.isEditing
          )
        }
      }
    }
    .padding()
  }

  var repoGridColumns: [GridItem] {
    let count: Int
    switch displaySize {
      case .small: count = 4
      case .medium: count = 3
      default: count = 2
    }

    #if os(tvOS)
      return Array(repeating: .init(.flexible()), count: count)
    #else
      let cols = CGFloat(count)
      return [GridItem(.adaptive(minimum: 640 / cols, maximum: .infinity))]
    #endif
  }
}

private struct RepoGridPreviewHost: View {
  @Namespace private var namespace
  @FocusState private var focus: Focus?

  var body: some View {
    RepoGridView(context: RepoContainerContext(namespace: namespace, runtime: .shared, focus: $focus))
      .frame(minWidth: 700, minHeight: 420)
  }
}

#Preview("Repo Grid", traits: .modifier(ActionStatusPreviews.Content())) {
  RepoGridPreviewHost()
}
