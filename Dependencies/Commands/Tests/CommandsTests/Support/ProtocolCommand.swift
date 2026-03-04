// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 21/01/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Foundation
import Testing

/// Example of a protocol that any command centre can implement.
/// Defining this sort of protocol allows commands to stay decoupled
/// from the specific command centre. As long as the command
/// just uses the protocol methods and properties, it can be
/// defined in a separate module from the centre itself.
/// This may have advantages for layering, and allows a
/// mock centre to be used for testing.
protocol TestProtocol: CommandCentre {
  func doTheThing()
}

/// Example of a command that just requires the command centre
/// to conform to TestProtocol. It can be written without knowing
/// that exact CommandCentre type it's going to be used with.
///
/// Note that this command can't see the definition of TestCentre.
struct ProtocolCommand<P: TestProtocol>: Command {
  let id = "test.protocol"

  func perform(centre: P) async throws {
    centre.doTheThing()
  }
}
