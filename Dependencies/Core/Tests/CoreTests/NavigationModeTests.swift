import XCTest

@testable import Core

final class NavigationModeTests: XCTestCase {
  /// Verifies that an unmodified click uses the primary click mode.
  func testPrimaryClickUsesPrimaryMode() {
    let mode = NavigationMode.resolve(
      for: .primaryClick,
      primaryClick: .edit,
      commandClick: .viewRepo,
      optionClick: .viewWorkflows
    )

    XCTAssertEqual(mode, .edit)
  }

  /// Verifies that a Command-click uses the configured command-click mode.
  func testCommandClickUsesCommandMode() {
    let mode = NavigationMode.resolve(
      for: .commandClick,
      primaryClick: .edit,
      commandClick: .viewRepo,
      optionClick: .viewWorkflows
    )

    XCTAssertEqual(mode, .viewRepo)
  }

  /// Verifies that an Option-click uses the configured option-click mode.
  func testOptionClickUsesOptionMode() {
    let mode = NavigationMode.resolve(
      for: .optionClick,
      primaryClick: .edit,
      commandClick: .viewRepo,
      optionClick: .viewWorkflows
    )

    XCTAssertEqual(mode, .viewWorkflows)
  }
}
