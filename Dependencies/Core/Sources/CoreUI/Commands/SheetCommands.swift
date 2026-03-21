// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CommandsUI
import Core
import Icons

/// Command that presents the edit sheet.
public struct ShowEditSheetCommand<C: SheetServiceProvider>: CommandWithUI {
  public let id = "sheet.edit"
  public let icon = Icon.actions

  let repo: Repo

  public init(repo: Repo) {
    self.repo = repo
  }

  public func perform(centre: C) async throws {
    centre.sheetService.showing = .editRepo(repo)
  }
}

/// Command that presents the preferences sheet.
public struct ShowPreferencesSheetCommand<C: SheetServiceProvider>: CommandWithUI {
  public let id = "sheet.preferences"
  public let icon = Icon.preferences

  public init() {
  }

  public func perform(centre: C) async throws {
    centre.sheetService.showing = .preferences
  }
}

/// Command that presents the auth debug sheet on iOS.
public struct ShowAuthDebugSheetCommand<C: SheetServiceProvider>: CommandWithUI {
  public let id = "sheet.auth-debug"
  public let icon = Icon.actions

  public init() {
  }

  public func perform(centre: C) async throws {
    centre.sheetService.showing = .authDebug
  }
}
