// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/09/2025.
//  Copyright © 2025 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import SwiftUI

public enum CommandError: Error {
  case commandUnavaiable
}

/// A centre that can perform commands.
@MainActor
public protocol CommandCentre {
  func recordStartedCommand<C: Command>(_ command: C) where C.Centre == Self
  func recordFinishedCommand<C: Command>(_ command: C) where C.Centre == Self
}


/// Default implementations of command-related functionality.
@MainActor
public extension CommandCentre {
 
  /// Return the availability of the given command.
  func availability<C: Command>(_ command: C) -> CommandAvailability where C.Centre == Self {
    let a = command.availability(centre: self)
    if isRunning(command) {
      return a == .hidden ? .runningSilently : .running
    } else {
      return a
    }
  }

  /// Perform the given command.
  func perform<C: Command>(_ command: C) async throws -> C.ResultType where C.Centre == Self {
    commandChannel.debug("performing command «\(command.id)»")
    
    // ideally, the UI should prevent any command from being performed
    // unless it is reporting its availability as `.enabled`.
    // a race condition might exist where it becomes unavailable
    // after perform is called, and so we check; this isn't foolproof
    // of course, since it could still become unavailable later,
    // and so commands should be prepared to have their perform() method
    // called when unavailable
    guard command.availability(centre: self) == .enabled else {
      throw CommandError.commandUnavaiable
    }

    recordStartedCommand(command)
    do {
      let result = try await command.perform(centre: self)
      recordFinishedCommand(command)
      return result
    } catch {
      recordFinishedCommand(command)
      throw error
    }
  }
  
  /// Perform the given command without waiting for the result.
  func performWithoutWaiting<C: Command>(_ command: C) where C.Centre == Self {
    commandChannel.debug("performing command «\(command.id)»")
    Task {
      do {
        _ = try await perform(command)
      } catch {
        commandChannel.log("Error performing command \(command.id): \(error)")
      }
    }
  }
  
  func recordStartedCommand<C: Command>(_ command: C) where C.Centre == Self {
  }
  
  func recordFinishedCommand<C: Command>(_ command: C) where C.Centre == Self {
  }
  
  func isRunning<C: Command>(_ command: C) -> Bool where C.Centre == Self {
    return false
  }
}
