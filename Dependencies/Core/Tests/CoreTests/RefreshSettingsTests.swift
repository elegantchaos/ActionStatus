// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Testing

@testable import Core

// MARK: - RefreshSettings

@MainActor
struct RefreshSettingsTests {
  /// Verifies that init stores all fields correctly.
  @Test
  func initStoresAllFields() {
    let settings = RefreshSettings(server: "api.github.com", token: "tok", interval: .minute)
    #expect(settings.server == "api.github.com")
    #expect(settings.token == "tok")
    #expect(settings.interval == .minute)
  }

  /// Two settings with the same values are equal.
  @Test
  func equalityHoldsForSameValues() {
    let a = RefreshSettings(server: "api.github.com", token: "tok", interval: .minute)
    let b = RefreshSettings(server: "api.github.com", token: "tok", interval: .minute)
    #expect(a == b)
  }

  /// Settings differing by server are not equal.
  @Test
  func inequalityOnDifferentServer() {
    let a = RefreshSettings(server: "api.github.com", token: "tok", interval: .minute)
    let b = RefreshSettings(server: "github.example.com", token: "tok", interval: .minute)
    #expect(a != b)
  }

  /// Settings differing by token are not equal.
  @Test
  func inequalityOnDifferentToken() {
    let a = RefreshSettings(server: "api.github.com", token: "tok1", interval: .minute)
    let b = RefreshSettings(server: "api.github.com", token: "tok2", interval: .minute)
    #expect(a != b)
  }

  /// Settings differing by interval are not equal.
  @Test
  func inequalityOnDifferentInterval() {
    let a = RefreshSettings(server: "api.github.com", token: "tok", interval: .minute)
    let b = RefreshSettings(server: "api.github.com", token: "tok", interval: .fiveMinute)
    #expect(a != b)
  }
}
