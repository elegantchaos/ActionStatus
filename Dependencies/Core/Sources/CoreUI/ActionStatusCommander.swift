import Commands
import Observation

/// Command centre shared by the app runtime and preview runtime.
///
/// Views depend on this concrete commander instead of the full engine so the
/// same command surface can be used in previews and in the running app.
@Observable
@MainActor
public final class ActionStatusCommander {
  /// Model service used by model commands.
  public let modelService: ModelService

  /// Settings service used by UI commands.
  public let settingsService: SettingsService

  /// Metadata service used by runtime-sensitive commands.
  public let metadataService: MetadataService

  /// Launch service used by URL and file commands.
  public let launchService: LaunchService

  /// Refresh service used by views that pause and resume updates.
  public let refreshService: RefreshService

  /// Sheet service used by presentation commands.
  public let sheetService: SheetService

  @ObservationIgnored private var addLocalReposAction: @MainActor () -> Void

  /// Creates a commander backed by the supplied services.
  public init(
    modelService: ModelService,
    settingsService: SettingsService,
    metadataService: MetadataService,
    launchService: LaunchService,
    refreshService: RefreshService,
    sheetService: SheetService,
    addLocalReposAction: @escaping @MainActor () -> Void = {}
  ) {
    self.modelService = modelService
    self.settingsService = settingsService
    self.metadataService = metadataService
    self.launchService = launchService
    self.refreshService = refreshService
    self.sheetService = sheetService
    self.addLocalReposAction = addLocalReposAction
  }

  /// Updates the local-repo import action used by menu and button commands.
  public func setAddLocalReposAction(_ action: @escaping @MainActor () -> Void) {
    addLocalReposAction = action
  }

  /// Performs the configured local-repo import action.
  public func addLocalRepos() {
    addLocalReposAction()
  }
}

extension ActionStatusCommander: CommandCentre {
}

extension ActionStatusCommander: LaunchServiceProvider {
}

extension ActionStatusCommander: LocalRepoImportingProvider {
}

extension ActionStatusCommander: MetadataServiceProvider {
}

extension ActionStatusCommander: ModelServiceProvider {
}

extension ActionStatusCommander: RefreshServiceProvider {
}

extension ActionStatusCommander: SettingsServiceProvider {
}

extension ActionStatusCommander: SheetServiceProvider {
}
