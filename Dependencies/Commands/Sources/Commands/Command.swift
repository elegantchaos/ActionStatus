// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/10/2025.
//  Copyright © 2025 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Logger

let commandChannel = Channel("Commands")


/// A command that can be performed by a CommandCentre.
@MainActor
public protocol Command<Centre> {
  /// The CommandCentre type that can perform this command.
  associatedtype Centre: CommandCentre
  
  /// The type of result returned when the command is performed.
  associatedtype ResultType
  
  /// A unique identifier for the command.
  var id: String { get }
  
  /// Determine whether the command is enabled, disabled, or hidden.
  func availability(centre: Centre) -> CommandAvailability
  
  /// Perform the command using the given CommandCentre.
  func perform(centre: Centre) async throws -> ResultType
}

/// Default implementations for Command protocol.
@MainActor
public extension Command {
  /// By default, commands are always enabled.
  func availability(centre: Centre) -> CommandAvailability { return .enabled }
  
//  func perform(centre: Centre) {
//    Task {
//      do {
//        _ = try await perform(centre: centre)
//      } catch {
//        commandChannel.log("Error performing command \(id): \(error)")
//      }
//    }
//  }
}
