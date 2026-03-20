import Testing

@testable import Core
@testable import CoreUI

@MainActor
struct ActionStatusPreviewRuntimeTests {
  private struct TestSettingsCentre: SettingsServiceProvider {
    let settingsService: SettingsService
  }

  @Test
  func testScenarioBuildSeedsFixtureAndRuntime() async {
    let repo = ActionStatusPreviews.repo("ActionStatus", owner: "elegantchaos", state: .passing)
    let scenario = ActionStatusPreviewScenario(repos: [repo], isEditing: true)

    let built = scenario.build()

    #expect(built.fixture.repos.count == 1)
    #expect(built.fixture.primaryRepo.name == "ActionStatus")
    #expect(built.runtime.commander.settingsService.isEditing)
    #expect(built.runtime.statusService.sortedRepos.count == 1)
  }

  @Test
  func testPreviewCommanderCanPerformSheetCommand() async throws {
    let scenario = ActionStatusPreviewScenario(repos: ActionStatusPreviews.sampleRepos())
    let commander = scenario.build().runtime.commander

    try await commander.perform(ShowPreferencesSheetCommand<ActionStatusCommander>())

    #expect(commander.sheetService.showing?.id == "preferences")
  }

  @Test
  func testToggleEditingCommandUsesConfiguredSettingsService() async throws {
    let commandSettings = SettingsService()
    let centreSettings = SettingsService()
    let command = ToggleEditingCommand<TestSettingsCentre>(settingsService: commandSettings)
    let centre = TestSettingsCentre(settingsService: centreSettings)

    #expect(!commandSettings.isEditing)
    #expect(!centreSettings.isEditing)

    try await command.perform(centre: centre)

    #expect(commandSettings.isEditing)
    #expect(!centreSettings.isEditing)
  }
}
