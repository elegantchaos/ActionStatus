// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/05/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import SwiftUI

/// Grid presentation of monitored repositories.
public struct RepoGridView: View {
  @Environment(StatusService.self) var status
  @Environment(SettingsService.self) var settings
  @AppStorage(.displaySize) var displaySize

  let namespace: Namespace.ID
  let focus: FocusState<Focus?>.Binding

  /// Creates a repository grid view.
  public init(namespace: Namespace.ID, focus: FocusState<Focus?>.Binding) {
    self.namespace = namespace
    self.focus = focus
  }

  public var body: some View {
    ScrollView(.vertical) {
      LazyVGrid(columns: repoGridColumns, spacing: 0) {
        ForEach(status.sortedRepos) { repo in
          RepoCellView(
            repo: repo,
            selectable: false,
            namespace: namespace,
            isSource: !settings.isEditing,
            focus: focus
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
