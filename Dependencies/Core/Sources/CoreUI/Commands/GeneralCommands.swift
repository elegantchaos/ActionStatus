// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Core
import Foundation
import Icons

public struct ToggleEditingCommand: CommandWithUI {
  public let id = "editing.toggle"
  public let icon = Icon.editButtonIcon
  public let settingsService: SettingsService
  public var shortcut: CommandShortcut? {
    .init("E", modifiers: [.command])
  }

  public var name: String {
    String(localized: settingsService.isEditing ? "editing.stop" : "editing.start")
  }

  public init(settingsService: SettingsService) {
    self.settingsService = settingsService
  }

  public func perform(centre: Engine) async throws {
    _ = centre.settingsService.toggleEditing()
  }
}

/// Command which opens the project on the web (eg in Github)
public struct ShowRepoCommand: CommandWithUI {
  public let id = "show.repo"
  public let icon = Icon.showRepoIcon
  let repo: Repo

  public func perform(centre: Engine) async throws {
    centre.launchService.open(url: repo.githubURL(for: .repo))
  }
}

/// Command which opens the workflow file on the web (eg in Github)
public struct ShowWorkflowCommand: CommandWithUI {
  public let id = "show.workflow"
  public let icon = Icon.showWorkflowIcon
  let repo: Repo

  public func perform(centre: Engine) async throws {
    centre.launchService.open(url: repo.githubURL(for: .workflow))
  }
}

/// Command which reveals the project locally.
public struct RevealLocalCommand: CommandWithUI {
  public let id = "reveal.repo"
  public let icon = Icon.revealLocalIcon
  let repo: Repo

  public func availability(centre: Engine) -> CommandAvailability {
    var status = CommandAvailability.disabled
    let deviceID = centre.metadataService.runtime.bundle.identifier
    if let url = repo.url(forDevice: deviceID) {
      url.accessSecurityScopedResource { unlockedURL in
        if FileManager.default.fileExists(atURL: url) {
          status = .enabled
        }
      }
    }

    return status
  }

  public func perform(centre: Engine) async throws {
    let deviceID = centre.metadataService.runtime.bundle.identifier
    if let url = repo.url(forDevice: deviceID) {
      url.accessSecurityScopedResource { unlockedURL in
        centre.launchService.reveal(url: unlockedURL)
      }
    }
  }
}
