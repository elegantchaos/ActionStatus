import Core
import CoreUI
import Previews
import SwiftUI

/// Fixture data exposed to ActionStatus preview closures.
@MainActor
public struct ActionStatusPreviewFixture {
  /// Seeded repositories available to the preview.
  public let repos: [Repo]

  /// Primary repository for single-entity previews.
  public let primaryRepo: Repo

  /// Optional selected repository for previews that need one.
  public let selectedRepo: Repo?

  /// Whether editing mode is enabled.
  public let isEditing: Bool

  /// Creates a preview fixture from the supplied repositories.
  public init(
    repos: [Repo],
    primaryRepo: Repo? = nil,
    selectedRepo: Repo? = nil,
    isEditing: Bool = false
  ) {
    self.repos = repos
    self.primaryRepo = primaryRepo ?? repos.first ?? Repo()
    self.selectedRepo = selectedRepo
    self.isEditing = isEditing
  }
}

/// Specialized preview scenario used by ActionStatus previews.
public typealias ActionStatusPreviewScenario = PreviewScenario<ActionStatusPreviewRuntime, ActionStatusPreviewFixture>

/// Preview-safe runtime for ActionStatus views.
///
/// This runtime mirrors the live app's environment graph, but seeds an in-memory
/// model store and disables side effects such as launching URLs and refresh work.
@MainActor
public final class ActionStatusPreviewRuntime: EnvironmentInjectingRuntime {
  /// Shared model service.
  public let modelService: ModelService

  /// Shared status service.
  public let statusService: StatusService

  /// Shared settings service.
  public let settingsService: SettingsService

  /// Shared metadata service.
  public let metadataService: MetadataService

  /// Shared launch service.
  public let launchService: LaunchService

  /// Shared refresh service.
  public let refreshService: RefreshService

  /// Shared sheet service.
  public let sheetService: SheetService

  /// Shared commander used by command-backed views.
  public let commander: ActionStatusCommander

  /// Creates a preview runtime for the supplied scenario inputs.
  public init(
    repos: [Repo],
    isEditing: Bool = false,
    initialSheet: SheetService.Sheet? = nil
  ) {
    let settingsService = SettingsService()
    let statusService = StatusService()
    let metadataService = MetadataService()
    let modelService = ModelService(
      repos,
      statusService: statusService,
      deviceIdentifier: metadataService.deviceIdentifier,
      store: PreviewModelStore(repos: repos)
    )
    settingsService.isEditing = isEditing

    let launchService = PreviewLaunchService()
    let authService = StubAuthService()
    let refreshConfig = StoredRefreshConfiguration()
    let refreshService = RefreshService(
      model: modelService,
      metadata: metadataService,
      authService: authService,
      interval: refreshConfig.refreshInterval,
      lastEventStore: UserDefaultsLastEventStore(),
      forcedType: RefreshService.RefreshType.none
    )
    let sheetService = SheetService()
    sheetService.showing = initialSheet

    self.modelService = modelService
    self.statusService = statusService
    self.settingsService = settingsService
    self.metadataService = metadataService
    self.launchService = launchService
    self.refreshService = refreshService
    self.sheetService = sheetService
    self.commander = ActionStatusCommander(
      modelService: modelService,
      settingsService: settingsService,
      metadataService: metadataService,
      launchService: launchService,
      refreshService: refreshService,
      sheetService: sheetService
    )

    statusService.connect(to: modelService)
  }

  /// Shared environment injector used by preview content.
  public var environmentInjector: ActionStatusEnvironmentInjector {
    ActionStatusEnvironmentInjector(
      commander: commander,
      modelService: modelService,
      metadataService: metadataService,
      settingsService: settingsService,
      launchService: launchService,
      statusService: statusService,
      refreshService: refreshService,
      refreshConfig: StoredRefreshConfiguration(),
      authService: StubAuthService(),
      sheetService: sheetService
    )
  }
}

public extension PreviewScenario where Runtime == ActionStatusPreviewRuntime, Fixture == ActionStatusPreviewFixture {
  /// Creates an ActionStatus preview scenario from seeded repositories.
  init(
    repos: [Repo],
    isEditing: Bool = false,
    initialSheet: SheetService.Sheet? = nil
  ) {
    self.init {
      let runtime = ActionStatusPreviewRuntime(
        repos: repos,
        isEditing: isEditing,
        initialSheet: initialSheet
      )
      let fixture = ActionStatusPreviewFixture(
        repos: repos,
        primaryRepo: repos.first,
        selectedRepo: repos.first,
        isEditing: isEditing
      )
      return PreviewBuilt(runtime: runtime, fixture: fixture)
    }
  }
}

/// Canned ActionStatus preview scenarios.
@MainActor
public enum ActionStatusPreviews {
  /// Empty-state content preview.
  public static let empty = ActionStatusPreviewScenario(repos: [])

  /// Standard content preview with mixed repository states.
  public static let content = ActionStatusPreviewScenario(repos: sampleRepos())

  /// Editing-mode content preview.
  public static let editing = ActionStatusPreviewScenario(repos: sampleRepos(), isEditing: true)

  /// Existing-repository edit preview.
  public static let editExisting = ActionStatusPreviewScenario(repos: sampleRepos(), isEditing: true)

  /// Passing repository cell preview.
  public static let repoCellPassing = repoCell(state: .passing)

  /// Failing repository cell preview.
  public static let repoCellFailing = repoCell(state: .failing, isEditing: true)

  /// Status menu preview with mixed states.
  public static let statusMenu = ActionStatusPreviewScenario(repos: sampleRepos())

  /// Creates a repository-cell scenario with the supplied state.
  public static func repoCell(
    state: Repo.State,
    isEditing: Bool = false,
    name: String = "ActionStatus",
    owner: String = "elegantchaos"
  ) -> ActionStatusPreviewScenario {
    ActionStatusPreviewScenario(
      repos: [repo(name, owner: owner, state: state)],
      isEditing: isEditing
    )
  }
  /// Creates a repository value for previews.
  public static func repo(
    _ name: String,
    owner: String,
    workflow: String = "Tests",
    state: Repo.State,
    branches: [String] = []
  ) -> Repo {
    Repo(name, owner: owner, workflow: workflow, state: state, branches: branches)
  }

  /// Creates a shared sample repository set for list and grid previews.
  public static func sampleRepos() -> [Repo] {
    [
      repo("ActionStatus", owner: "elegantchaos", state: .passing),
      repo("Commands", owner: "elegantchaos", state: .queued),
      repo("Runtime", owner: "elegantchaos", state: .running),
      repo("Website", owner: "elegantchaos", state: .failing),
      repo("Settings", owner: "elegantchaos", state: .dormant),
      repo("Application", owner: "elegantchaos", state: .partiallyFailing),
    ]
  }
}

/// In-memory model store used by ActionStatus previews.
private final class PreviewModelStore: ModelStore {
  var values: Values

  init(repos: [Repo]) {
    values = Dictionary(uniqueKeysWithValues: repos.map { ($0.id, $0) })
  }

  var debugLabel: String { "preview" }

  func get(forKey key: String) -> Repo? {
    values[key]
  }

  func set(_ repo: Repo, forKey key: String) {
    values[key] = repo
  }

  func remove(forKey key: String) {
    values.removeValue(forKey: key)
  }

  func onChange(_ callback: @escaping ChangeCallback) async {
    await callback(values)
  }
}

/// Launch service used in previews to avoid side effects.
private final class PreviewLaunchService: LaunchService {
  override func open(url: URL) {
  }

  override func reveal(url: URL) {
  }
}
