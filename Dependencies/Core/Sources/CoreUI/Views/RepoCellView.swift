// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Runtime
import SwiftUI

/// Cell view that renders a repository and its primary status affordances.
public struct RepoCellView: View {
  @Environment(ActionStatusCommander.self) var commander
  @Environment(MetadataService.self) var metadataService

  @AppStorage(.displaySize) var displaySize

  let repo: Repo
  let selectable: Bool
  let namespace: Namespace.ID
  let isSource: Bool
  let focus: FocusState<Focus?>.Binding

  /// Creates a repository cell view.
  public init(
    repo: Repo,
    selectable: Bool,
    namespace: Namespace.ID,
    isSource: Bool = true,
    focus: FocusState<Focus?>.Binding
  ) {
    self.repo = repo
    self.selectable = selectable
    self.namespace = namespace
    self.isSource = isSource
    self.focus = focus
  }

  public var body: some View {
    commander.button(NavigateRepoCommand(repo: repo)) {
      repoLabel()
    }
    .padding(cellPadding)
    #if os(tvOS)
      .buttonStyle(FadingFocusButtonStyle())
      .focused(focus, equals: .repo(repo.id))
    #else
      .buttonStyle(.plain)
    #endif
    .font(displaySize.font)
    .foregroundColor(.primary)
    .contextMenu(menuItems: contextMenuContent)
  }

  @ViewBuilder
  func contextMenuContent() -> some View {
    Label(repo.name, icon: .repoIcon)

    commander.button(ShowEditSheetCommand(repo: repo))
    commander.button(ShowRepoCommand(repo: repo))
    commander.button(ShowWorkflowCommand(repo: repo))
    commander.button(RevealLocalCommand(repo: repo))

    Divider()

    commander.button(RemoveReposCommand(ids: [repo.id]))
    if metadataService.showDebugUI {
      Divider()
      commander.button(AdvanceStateCommand(repo: repo))
    }
  }

  func repoLabel() -> some View {
    HStack(alignment: .center, spacing: .padding) {
      Image(systemName: repo.badgeName)
        .foregroundColor(repo.statusColor)

      Text(repo.name)
        .allowsTightening(true)
        .truncationMode(.middle)
        .lineLimit(1)

      Spacer()
    }
    .matchedGeometryEffect(id: repo.id, in: namespace, isSource: isSource)
  }

  var cellPadding: CGFloat {
    #if os(tvOS)
      return 0
    #else
      return 4
    #endif
  }
}
