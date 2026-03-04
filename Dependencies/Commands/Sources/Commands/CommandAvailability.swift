// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/10/2025.
//  Copyright © 2025 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation


/// Indicates whether a command is enabled, disabled, or hidden.
public enum CommandAvailability {
  /// The command can be used.
  case enabled
  
  /// The command is visible but cannot be used, for example,
  /// because the current context does not support it.
  /// It should be shown as disabled in the UI.
  case disabled
  
  /// The command should not be shown in the UI at all.
  /// This could be true because it will never be applicable in the current context,
  /// for example because it's not supported on the current platform,
  /// or because the user has chosen to hide it.
  /// It does not *necessarily* imply that the command cannot be executed programmatically.
  case hidden
  
  /// The command is currently executing.
  /// It may therefore to disable further invocations until it has completed.
  case running
  
  /// The command is currently executing silently.
  /// This could mean that it is running in the background,
  /// or that it was invoked in a way that did not involve user interaction.
  case runningSilently
}
