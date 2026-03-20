import Testing

@testable import Core
@testable import CoreUI

@MainActor
struct ActionStatusPreviewRuntimeTests {
  private struct TestSettingsCentre: SettingsServiceProvider {
    let settingsService: SettingsService
  }

  @Test
  func testEditingPreviewPresetBuildsExpectedRuntime() async throws {
    let repo = ActionStatusPreviews.repo("ActionStatus", owner: "elegantchaos", state: .passing)
    let runtime = ActionStatusPreviewRuntime(repos: [repo], isEditing: true)

    #expect(runtime.commander.settingsService.isEditing)
    #expect(runtime.statusService.sortedRepos.count == 1)
    #expect(runtime.statusService.sortedRepos.first?.name == repo.name)
  }

  @Test
  func testPreviewCommanderCanPerformSheetCommand() async throws {
    let runtime = try await ActionStatusPreviews.Content.makeSharedContext()
    let commander = runtime.commander

    try await commander.perform(ShowPreferencesSheetCommand<ActionStatusCommander>())

    #expect(commander.sheetService.showing?.id == "preferences")
  }

  @Test
  func testEditingPresetBuildsExpectedSharedContext() async throws {
    let runtime = try await ActionStatusPreviews.Editing.makeSharedContext()

    #expect(runtime.settingsService.isEditing)
    #expect(runtime.statusService.sortedRepos.count == ActionStatusPreviews.Editing.repos.count)
    #expect(runtime.sheetService.showing == nil)
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
