// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/10/2025.
//  Copyright © 2025 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Icons
import Foundation
import SwiftUI

/// Command which wraps another command, and changes some aspect of it.
/// It has override points for all of the Command protocol methods,
/// so you can override just the ones you want to change.
open class WrappedCommand<C: CommandWithUI>: CommandWithUI {
  public typealias Centre = C.Centre

  open var id: String { command.id }
  open var icon: Icon { command.icon }
  open var name: String { command.name }
  open var shortcut: CommandShortcut? { command.shortcut }
  open var help: String? { command.help }
  open var confirmation: CommandConfirmation? { command.confirmation }
  open var bundle: Bundle { command.bundle }

  let command: C

  public init(_ command: C) {
    self.command = command
  }

  open func availability(centre: C.Centre) -> CommandAvailability {
    return command.availability(centre: centre)
  }

  open func perform(centre: C.Centre) async throws -> C.ResultType {
    return try await command.perform(centre: centre)
  }


}
