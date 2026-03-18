// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Core
import Foundation
import Icons
import Runtime

/// Command that toggles repository editing mode.
public struct ToggleEditingCommand<C: SettingsServiceProvider>: CommandWithUI {
  public let id = "editing.toggle"
  public let settingsService: SettingsService

  public var shortcut: CommandShortcut? {
    .init("E", modifiers: [.command])
  }

  public var icon: Icon {
    settingsService.isEditing ? .startEditing : .stopEditing
  }

  public var name: String {
    String(localized: settingsService.isEditing ? "editing.stop" : "editing.start")
  }

  public init(settingsService: SettingsService) {
    self.settingsService = settingsService
  }

  public func perform(centre: C) async throws {
    _ = settingsService.toggleEditing()
  }
}

/// Command which opens the project on the web.
struct ShowRepoCommand<C: LaunchServiceProvider>: CommandWithUI {
  let id = "show.repo"
  let icon = Icon.showRepo
  let repo: Repo

  func perform(centre: C) async throws {
    centre.launchService.open(url: repo.githubURL(for: .repo))
  }
}

/// Command which opens the workflow page on the web.
struct ShowWorkflowCommand<C: LaunchServiceProvider>: CommandWithUI {
  let id = "show.workflow"
  let icon = Icon.showWorkflow
  let repo: Repo

  func perform(centre: C) async throws {
    centre.launchService.open(url: repo.githubURL(for: .workflow))
  }
}

/// Command which reveals the project locally.
struct RevealLocalCommand<C: LaunchServiceProvider>: CommandWithUI {
  let id = "reveal.repo"
  let icon = Icon.revealLocalRepo
  let repo: Repo
  let deviceID: String?

  init(repo: Repo, runtime: Runtime = .shared) {
    self.repo = repo
    self.deviceID = runtime.deviceIdentifier
  }
  
  func availability(centre: C) -> CommandAvailability {
    var status = CommandAvailability.disabled
    if let url = repo.localURL(forDevice: deviceID) {
      url.accessSecurityScopedResource { unlockedURL in
        if FileManager.default.fileExists(atURL: unlockedURL) {
          status = .enabled
        }
      }
    }

    return status
  }

  func perform(centre: C) async throws {
    if let url = repo.localURL(forDevice: deviceID) {
      url.accessSecurityScopedResource { unlockedURL in
        centre.launchService.reveal(url: unlockedURL)
      }
    }
  }
}

/// Command which follows the configured navigation action for a repository.
struct NavigateRepoCommand<C: LaunchServiceProvider & SheetServiceProvider & SettingsServiceProvider>: CommandWithUI {
  let id = "navigate.repo"
  let icon = Icon.showRepo
  let repo: Repo
  let mode: NavigationMode

  public init(repo: Repo, mode: NavigationMode) {
    self.repo = repo
    self.mode = mode
  }

  func perform(centre: C) async throws {
    switch mode {
      case .edit:
        centre.sheetService.showing = .editRepo(repo)
      case .viewRepo:
        centre.launchService.open(url: repo.githubURL(for: .repo))
      case .viewWorkflows:
        centre.launchService.open(url: repo.githubURL(for: .workflow))
    }
  }
}
