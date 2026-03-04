// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 21/01/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Foundation
import Testing

/// Example of a simple, concrete command centre.
/// This exists to supply context to the individual commands.
/// It can supply this context by exposing public properties
/// and functions which the commands can use.
private class TestCentre: CommandCentre {
  var testRan = false
  var didTheThing = false
}

// MARK: - Simple Command

/// Example of a simple command.
/// It is specialised on a specific command centre,
/// and so needs to be defined in a module where
/// that centre is visible, which probably means
/// somewhere quite high level.
private struct TestCommand: Command {
  let id = "test.command"
  
  /// Availability to report.
  let mockAvailablity: CommandAvailability
  
  init(reportingAvailabilityAs mockAvailability: CommandAvailability = .enabled) {
    self.mockAvailablity = mockAvailability
  }

  /// Report whether we're available.
  /// Normal commands would use the centre to dynamically figure out if they
  /// are available or not.
  /// Simple commands can just use the default implementation of availability(), which always
  /// returns .enabled.
  /// For testing purposes, this command returns the mock availability we created it with.
  func availability(centre: TestCentre) -> CommandAvailability {
    mockAvailablity
  }

  func perform(centre: TestCentre) async throws {
    centre.testRan = true
  }
}

/// Test that the simple command performs ok.
@Test func testSimpleCommand() async throws {
  let centre = TestCentre()
  let command = TestCommand()
  #expect(centre.availability(command) == .enabled)
  #expect(centre.testRan == false)
  try await centre.perform(command)
  #expect(centre.testRan == true)
}

/// Test that the hidden command performs ok.
@Test func testHiddenCommand() async throws {
  let centre = TestCentre()
  let command = TestCommand(reportingAvailabilityAs: .hidden)
  #expect(centre.availability(command) == .hidden)
  #expect(centre.testRan == false)
  await #expect(throws: CommandError.commandUnavaiable) {
    try await centre.perform(command)
  }
  #expect(centre.testRan == false)
}


// MARK: - Protocol Based Command

/// Conform our concrete test centre to the protocol.
extension TestCentre: TestProtocol {
  func doTheThing() {
    didTheThing = true
  }
}

/// Example of a command that uses a protocol for its implementation.
/// It doesn't know about TestCentre, only about TestProtocol, but
/// since TestCentre implements TestProtocol, it can perform the command.
@Test func testProtocolCommand() async throws {
  let centre = TestCentre()
  #expect(centre.didTheThing == false)
  try await centre.perform(ProtocolCommand())
  #expect(centre.didTheThing == true)
}
