// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CommandsUI
import Core
import Icons

struct ShowEditSheetCommand: CommandWithUI {
  let id = "sheet.add"
  let icon = Icon.editButtonIcon

  let repo: Repo?

  public init(repo: Repo? = nil) {
    self.repo = repo
  }

  public func perform(centre: Engine) async throws {
    centre.sheetService.showing = .editRepo(repo)
  }
}

struct ShowPreferencesSheetCommand: CommandWithUI {
  let id = "sheet.preferences"
  let icon = Icon.addIcon

  public func perform(centre: Engine) async throws {
    centre.sheetService.showing = .preferences
  }


}
