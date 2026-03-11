import XCTest

@testable import Core
@testable import CoreUI
@testable import CoreUIPreviews

@MainActor
final class ActionStatusPreviewRuntimeTests: XCTestCase {
  func testScenarioBuildSeedsFixtureAndRuntime() {
    let repo = ActionStatusPreviews.repo("ActionStatus", owner: "elegantchaos", state: .passing)
    let scenario = ActionStatusPreviewScenario(repos: [repo], isEditing: true)

    let built = scenario.build()

    XCTAssertEqual(built.fixture.repos.count, 1)
    XCTAssertEqual(built.fixture.primaryRepo.name, "ActionStatus")
    XCTAssertTrue(built.runtime.commander.settingsService.isEditing)
    XCTAssertEqual(built.runtime.statusService.sortedRepos.count, 1)
  }

  func testPreviewCommanderCanPerformSheetCommand() async throws {
    let scenario = ActionStatusPreviewScenario(repos: ActionStatusPreviews.sampleRepos())
    let commander = scenario.build().runtime.commander

    try await commander.perform(ShowPreferencesSheetCommand<ActionStatusCommander>())

    XCTAssertEqual(commander.sheetService.showing?.id, "preferences")
  }
}
