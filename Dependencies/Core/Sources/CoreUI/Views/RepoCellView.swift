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

  /// Size of text and icons in the cell, configured by the user.
  @AppStorage(.displaySize) var displaySize

  /// Navigation mode to use when the cell is triggered with the primary command trigger.
  /// This is a plain click or tap.
  @AppStorage(.navigationMode) var navigationMode

  /// Navigation mode to use when the cell is triggered with the secondary command trigger.
  /// This is a command-click on macOS.
  @AppStorage(.secondaryNavigationMode) var secondaryNavigationMode

  /// Navigation mode to use when the cell is triggered with the tertiary command trigger.
  /// This is an option-click on macOS.
  @AppStorage(.tertiaryNavigationMode) var tertiaryNavigationMode

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
      NavigateRepoCommand<ActionStatusCommander>(repo: repo, mode: repoNavigationMode(for: trigger))
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

  /// Returns the configured navigation mode for the supplied trigger.
  private func repoNavigationMode(for trigger: CommandTrigger) -> NavigationMode {
    return switch trigger {
      case .primary:
        navigationMode
      case .secondary:
        secondaryNavigationMode
      case .tertiary:
        tertiaryNavigationMode
    }
  }
}

private struct RepoCellPreviewHost: View {
  @Namespace private var namespace
  @FocusState private var focus: Focus?

  let repo: Repo

  var body: some View {
    let context = RepoContainerContext(namespace: namespace, runtime: .shared, focus: $focus)
    RepoCellView(repo: repo, context: context, selectable: false)
      .frame(width: 320)
      .padding()
  }
}

#Preview("Repo Cell Passing", traits: .modifier(ActionStatusPreviews.Content())) {
  RepoCellPreviewHost(repo: ActionStatusPreviews.repoCellPassing)
}

#Preview("Repo Cell Failing", traits: .modifier(ActionStatusPreviews.Editing())) {
  RepoCellPreviewHost(repo: ActionStatusPreviews.repoCellFailing)
}
