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

  #if os(tvOS)
    let focus: FocusState<Focus?>.Binding
  #endif

  var body: some View {
    let cell = cell(for: repo)
    return cell.contextMenu(menuItems: contextMenuContent)
  }

  @ViewBuilder
  func contextMenuContent() -> some View {
    Text("\(repo.name)")

    engine.button(ShowEditSheetCommand(repo: repo))

    Button(action: handleShowRepo) {
      Label("Open In Github…", icon: .linkIcon)
    }

    Button(action: handleShowWorkflow) {
      Label("Open Workflow In Github…", icon: .linkIcon)
    }

    if let url = repo.url(forDevice: Device().identifier) {
      Button(
        action: { handleReveal(url: url) },
        label: {
          Label("Reveal In Finder…", icon: .linkIcon)
        })
    }

    Divider()

    engine.button(RemoveReposCommand(ids: [repo.id]))
    #if DEBUG
    if !metadataService.isUITestingBuild {
      Divider()
      engine.button(AdvanceStateCommand(repo: repo))
    }
    #endif
  }

  func cell(for repo: Repo) -> some View {
    if selectable {
      return AnyView(
        HStack(alignment: .center, spacing: .padding) {
          Text(repo.name)
            .allowsTightening(true)
            .truncationMode(.middle)
            .lineLimit(1)

          Spacer()
          engine.button(ShowEditSheetCommand(repo: repo))
        }
        .matchedGeometryEffect(id: repo.id, in: namespace)
        .padding(cellPadding)
        .font(displaySize.font)
        .foregroundColor(.primary))
    } else {
      return AnyView(
        Button(action: handleShowWorkflow) {
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
        .padding(cellPadding)
        .font(displaySize.font)
        .foregroundColor(.primary)
        #if os(tvOS)
          .buttonStyle(FadingFocusButtonStyle())
          .focused(focus, equals: .repo(repo.id))
        #else
          .buttonStyle(.plain)
        #endif
      )
    }
  }

  func handleShowRepo() {
    launchService.open(url: repo.githubURL(for: .repo))
  }

  func handleShowWorkflow() {
    launchService.open(url: repo.githubURL(for: .workflow))
  }

  func handleReveal(url: URL) {
    url.accessSecurityScopedResource { unlockedURL in
      launchService.reveal(url: unlockedURL)
    }
  }

  var cellPadding: CGFloat {
    #if os(tvOS)
      return 0
    #else
      return 4
    #endif
  }
}
