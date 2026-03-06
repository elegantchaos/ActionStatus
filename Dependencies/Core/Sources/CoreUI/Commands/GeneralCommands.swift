// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Icons
import CommandsUI

public struct ToggleEditingCommand: CommandWithUI {
  public let id = "editing.toggle"
  public let icon = Icon.editButtonIcon
  public var shortcut: CommandShortcut? {
    .init("E", modifiers: [.command])
  }
  
  public init() { }
  
  public func perform(centre: Engine) async throws {
    _ = centre.settingsService.toggleEditing()
  }
}
