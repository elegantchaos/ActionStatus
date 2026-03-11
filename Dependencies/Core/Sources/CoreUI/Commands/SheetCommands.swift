// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CommandsUI
import Core
import Icons

public struct ShowEditSheetCommand: CommandWithUI {
  public let id = "sheet.add"
  public let icon = Icon.editButtonIcon

  let repo: Repo?

  public init(repo: Repo? = nil) {
    self.repo = repo
  }

  public func perform(centre: Engine) async throws {
    centre.sheetService.showing = .editRepo(repo)
  }
}

public struct ShowPreferencesSheetCommand: CommandWithUI {
  public let id = "sheet.preferences"
  public let icon = Icon.preferencesIcon

  public init() { }

  public func perform(centre: Engine) async throws {
    centre.sheetService.showing = .preferences
  }


}
