// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Core
import Runtime
import SwiftUI

/// Cell view that renders a repository and its primary status affordances.
public struct RepoCellView: View {
  @Environment(ActionStatusCommander.self) var commander

  @AppStorage(.displaySize) var displaySize

  let repo: Repo
  let selectable: Bool
  let isSource: Bool
  let context: RepoContainerContext

  /// Creates a repository cell view.
  public init(
    repo: Repo,
    context: RepoContainerContext,
    selectable: Bool,
    isSource: Bool = true,
  ) {
    self.repo = repo
    self.selectable = selectable
    self.context = context
    self.isSource = isSource
  }

  public var body: some View {
    commander.dynamicButton { (trigger: CommandTrigger) in
      NavigateRepoCommand<ActionStatusCommander>(repo: repo, trigger: trigger)
    } content: {
      repoLabel()
    }
    .padding(cellPadding)
    #if os(tvOS)
      .buttonStyle(FadingFocusButtonStyle())
      .focused(context.focus, equals: .repo(repo.id))
    #else
      .buttonStyle(.plain)
    #endif
    .font(displaySize.font)
    .foregroundColor(.primary)
    .contextMenu(menuItems: contextMenuContent)
  }

  @ViewBuilder
  func contextMenuContent() -> some View {
    Label(repo.name, icon: .repo)

    commander.button(ShowEditSheetCommand(repo: repo))
    commander.button(ShowRepoCommand(repo: repo))
    commander.button(ShowWorkflowCommand(repo: repo))
    commander.button(RevealLocalCommand(repo: repo))

    Divider()

    commander.button(RemoveReposCommand(ids: [repo.id]))
    if context.runtime.showDebugUI {
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
    .matchedGeometryEffect(id: repo.id, in: context.namespace, isSource: isSource)
  }

  var cellPadding: CGFloat {
    #if os(tvOS)
      return 0
    #else
      return 4
    #endif
  }
}
