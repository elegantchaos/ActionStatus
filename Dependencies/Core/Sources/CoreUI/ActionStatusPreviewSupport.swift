import Core
import Runtime
import SwiftUI

/// Preview-safe runtime for ActionStatus views.
///
/// This runtime mirrors the live app's environment graph, but seeds an in-memory
/// model store and disables side effects such as launching URLs and refresh work.
@MainActor
public final class ActionStatusPreviewRuntime {
  /// Shared model service.
  public let modelService: ModelService

  /// Shared status service.
  public let statusService: StatusService

  /// Shared settings service.
  public let settingsService: SettingsService

  /// Shared launch service.
  public let launchService: LaunchService

  /// Shared auth service.
  public let authService: AuthService

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
    initialSheet: SheetService.Sheet? = nil,
    authState: GithubAuthState = .signedIn(GithubCredentials(login: "preview", server: "api.github.com", token: "preview-token")),
    authService: AuthService? = nil
  ) {
    let settingsService = SettingsService()
    let statusService = StatusService()
    let modelService = ModelService(
      repos,
      deviceIdentifier: Runtime.shared.deviceIdentifier,
      store: PreviewModelStore(repos: repos)
    )
    statusService.connect(to: modelService)
    settingsService.isEditing = isEditing

    let launchService = PreviewLaunchService()
    let authService = authService ?? AuthService.stub(initialState: authState)
    let refreshService = RefreshService(
      model: modelService,
      type: .none,
      interval: .automatic,
      lastEventStore: UserDefaultsLastEventStore()
    )
    refreshService.connect(to: authService)
    let sheetService = SheetService()
    sheetService.showing = initialSheet

    self.modelService = modelService
    self.statusService = statusService
    self.settingsService = settingsService
    self.launchService = launchService
    self.authService = authService
    self.refreshService = refreshService
    self.sheetService = sheetService
    self.commander = ActionStatusCommander(
      modelService: modelService,
      settingsService: settingsService,
      launchService: launchService,
      refreshService: refreshService,
      sheetService: sheetService
    )
  }

  /// Shared environment injector used by preview content.
  public var environmentInjector: ActionStatusEnvironmentInjector {
    ActionStatusEnvironmentInjector(
      commander: commander,
      modelService: modelService,
      settingsService: settingsService,
      launchService: launchService,
      statusService: statusService,
      refreshService: refreshService,
      authService: authService,
      sheetService: sheetService
    )
  }
}

@MainActor
public protocol ActionStatusPreviewPreset: PreviewModifier {
  static var repos: [Repo] { get }
  static var isEditing: Bool { get }
  static var initialSheet: SheetService.Sheet? { get }
  static var authState: GithubAuthState { get }
  static func makeAuthService() -> AuthService?
}

public extension ActionStatusPreviewPreset {
  static var isEditing: Bool { false }
  static var initialSheet: SheetService.Sheet? { nil }
  static var authState: GithubAuthState {
    .signedIn(GithubCredentials(login: "preview", server: "api.github.com", token: "preview-token"))
  }

  static func makeAuthService() -> AuthService? { nil }

  static func makeSharedContext() async throws -> ActionStatusPreviewRuntime {
    ActionStatusPreviewRuntime(
      repos: repos,
      isEditing: isEditing,
      initialSheet: initialSheet,
      authState: authState,
      authService: makeAuthService()
    )
  }

  func body(content: Content, context: ActionStatusPreviewRuntime) -> some View {
    content.modifier(context.environmentInjector)
  }
}

/// Canned ActionStatus preview scenarios.
@MainActor
public enum ActionStatusPreviews {
  public struct Empty: ActionStatusPreviewPreset {
    public static let repos: [Repo] = []

    public init() {}
  }

  public struct Content: ActionStatusPreviewPreset {
    public static let repos = seededRepos

    public init() {}
  }

  public struct Editing: ActionStatusPreviewPreset {
    public static let repos = seededRepos
    public static let isEditing = true

    public init() {}
  }

  public struct StatusMenu: ActionStatusPreviewPreset {
    public static let repos = seededRepos

    public init() {}
  }

  public struct AuthSignedOut: ActionStatusPreviewPreset {
    public static let repos = seededRepos
    public static let authState = GithubAuthState.signedOut

    public init() {}
  }

  public struct AuthValidating: ActionStatusPreviewPreset {
    public static let repos = seededRepos
    public static let authState = GithubAuthState.validating(GithubCredentials(login: "preview", server: "api.github.com", token: "preview-token"))

    public init() {}
  }

  public struct AuthFailed: ActionStatusPreviewPreset {
    public static let repos = seededRepos
    public static let authState = GithubAuthState.failed("Preview auth failure.")

    public init() {}
  }

  public struct AuthDebug: ActionStatusPreviewPreset {
    public static let repos = seededRepos

    public init() {}

    public static func makeAuthService() -> AuthService? {
      AuthService.simulated(initialScenario: .signedIn)
    }
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

  /// Shared sample repository set for list and grid previews.
  public static let seededRepos: [Repo] = [
    repo("ActionStatus", owner: "elegantchaos", state: .passing),
    repo("Commands", owner: "elegantchaos", state: .queued),
    repo("Runtime", owner: "elegantchaos", state: .running),
    repo("Website", owner: "elegantchaos", state: .failing),
    repo("Settings", owner: "elegantchaos", state: .dormant),
    repo("Application", owner: "elegantchaos", state: .partiallyFailing),
  ]

  /// Creates a shared sample repository set for list and grid previews.
  public static func sampleRepos() -> [Repo] {
    seededRepos
  }

  public static let editingRepo = repo("ActionStatus", owner: "elegantchaos", state: .passing)
  public static let repoCellPassing = repo("ActionStatus", owner: "elegantchaos", state: .passing)
  public static let repoCellFailing = repo("ActionStatus", owner: "elegantchaos", state: .failing)
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

  func onChange(_ perform: @escaping ChangeCallback) async {
    await perform(values)
  }
}

private final class PreviewLaunchService: LaunchService {
  override func open(url: URL) {}

  override func reveal(url: URL) {}
}
