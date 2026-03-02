// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Runtime
import SwiftUI

struct RepoCellView: View {
  @Environment(LaunchService.self) private var launchService
  @Environment(SettingsService.self) private var settingsService
  @Environment(SheetService.self) private var sheetService
  @Environment(Model.self) var model

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

    Button(action: handleEdit) {
      Label("Settings…", icon: .editButtonIcon)
        .accessibility(identifier: "editLabel")
    }

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

    Button(action: handleDelete) {
      Label("Delete", icon: .deleteRepoIcon)
    }
    #if DEBUG

      if !ProcessInfo.processInfo.environment.isTestingUI {
        Divider()
        Button(action: handleToggleState) {
          Text("DEBUG: Advance State")
        }
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
          Button(action: handleEdit) {
            Image(icon: .editButtonIcon)
          }
          .accessibility(identifier: "editButton")
          .foregroundColor(.black)
        }
        .matchedGeometryEffect(id: repo.id, in: namespace)
        .padding(cellPadding)
        .font(settingsService.settings.displaySize.font)
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
        .font(settingsService.settings.displaySize.font)
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

  func handleEdit() {
    sheetService.presentedSheet = .editRepo(repo)
  }

  func handleDelete() {
    model.remove(reposWithIDs: [repo.id])
  }

  func handleToggleState() {
    if let newState = Repo.State(rawValue: (repo.state.rawValue + 1) % UInt(Repo.State.allCases.count)) {
      model.update(repoWithID: repo.id, state: newState)
    }
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
