// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Runtime
import SwiftUI

struct RepoCellView: View {
  @Environment(LaunchService.self) private var launchService
  @Environment(Engine.self) var engine
  @Environment(MetadataService.self) var metadataService

  @AppStorage(.displaySize) var displaySize

  let repo: Repo
  let selectable: Bool
  let namespace: Namespace.ID

  let focus: FocusState<Focus?>.Binding

  var body: some View {
    let cell = cell(for: repo)
    return cell.contextMenu(menuItems: contextMenuContent)
  }

  @ViewBuilder
  func contextMenuContent() -> some View {
    Label(repo.name, icon: .repoIcon)

    engine.button(ShowEditSheetCommand(repo: repo))
    engine.button(ShowRepoCommand(repo: repo))
    engine.button(ShowWorkflowCommand(repo: repo))
    engine.button(RevealLocalCommand(repo: repo))

    Divider()

    engine.button(RemoveReposCommand(ids: [repo.id]))
    if metadataService.showDebugUI {
      Divider()
      engine.button(AdvanceStateCommand(repo: repo))
    }
  }

  func cell(for repo: Repo) -> some View {
    Group {
      if selectable {
        HStack(alignment: .center, spacing: .padding) {
          repoLabel()
          engine.button(ShowEditSheetCommand(repo: repo))
            .labelStyle(.iconOnly)
        }
        .padding(cellPadding)
      } else {
        engine.button(ShowRepoCommand(repo: repo)) {
          repoLabel()
        }
        .padding(cellPadding)
        #if os(tvOS)
          .buttonStyle(FadingFocusButtonStyle())
          .focused(focus, equals: .repo(repo.id))
        #else
          .buttonStyle(.plain)
        #endif
      }
    }
    .font(displaySize.font)
    .foregroundColor(.primary)
  }

  func handleReveal(url: URL) {
    url.accessSecurityScopedResource { unlockedURL in
      launchService.reveal(url: unlockedURL)
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
    .matchedGeometryEffect(id: repo.id, in: namespace)
  }
  
  var cellPadding: CGFloat {
    #if os(tvOS)
      return 0
    #else
      return 4
    #endif
  }
}
