// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Testing

@testable import Core

// MARK: - StatusService Sort Mode

@MainActor
struct StatusServiceSortModeTests {
  /// Applying a new sort mode stores it on the service.
  @Test
  func applySortModeStoresValue() {
    let service = StatusService()
    service.apply(sortMode: .name)
    #expect(service.sortMode == .name)
  }

  /// Applying the same sort mode twice is idempotent.
  @Test
  func applySortModeIdempotent() {
    let service = StatusService()
    service.apply(sortMode: .state)
    service.apply(sortMode: .state)
    #expect(service.sortMode == .state)
  }

  /// Toggling sort modes updates the stored value.
  @Test
  func applySortModeToggles() {
    let service = StatusService()
    service.apply(sortMode: .name)
    #expect(service.sortMode == .name)
    service.apply(sortMode: .state)
    #expect(service.sortMode == .state)
  }
}
