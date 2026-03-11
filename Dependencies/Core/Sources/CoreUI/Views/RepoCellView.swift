// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Runtime
import SwiftUI
#if os(macOS)
  import AppKit
#endif

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
    Button(action: performNavigation) {
      repoLabel()
    }
    .padding(cellPadding)
    #if os(tvOS)
      .buttonStyle(FadingFocusButtonStyle())
      .focused(focus, equals: .repo(repo.id))
    #else
      .buttonStyle(.plain)
    #endif
    .disabled(commander.shouldDisable(navigationCommand(for: .primaryClick)))
    .font(displaySize.font)
    .foregroundColor(.primary)
    .contextMenu(menuItems: contextMenuContent)
  }

  /// Performs the configured navigation action for the current click trigger.
  func performNavigation() {
    // TODO: Extract repo navigation rules into a NavigationService so trigger handling
    // and destination selection are explicit and easier to evolve.
    commander.performWithoutWaiting(navigationCommand(for: navigationTrigger))
  }

  /// Builds the navigation command for the specified click trigger.
  func navigationCommand(for trigger: NavigationTrigger) -> NavigateRepoCommand {
    NavigateRepoCommand(repo: repo, trigger: trigger)
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

  /// Returns the click trigger for the current platform event.
  var navigationTrigger: NavigationTrigger {
    #if os(macOS)
      let modifiers = NSApp.currentEvent?.modifierFlags ?? []
      if modifiers.contains(.command) {
        return .commandClick
      }
      if modifiers.contains(.option) {
        return .optionClick
      }
    #endif

    return .primaryClick
  }
}
