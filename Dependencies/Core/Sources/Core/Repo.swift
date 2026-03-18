// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import DictionaryCoding
import Files
import Foundation

nonisolated private extension URL {
  var bookmarkKey: String { "bookmark:\(absoluteURL.path)" }
}

/// A monitored GitHub repository and its runtime state.
///
/// `Repo` is the central model value: it carries the identity (`id`, `owner`, `name`),
/// the set of selected workflows, and the aggregated CI state produced by the refresh layer.
/// All mutation goes through `ModelService` so `NSUbiquitousKeyValueStore` stays in sync.
///
/// `id` is a stable UUID string assigned at creation time and never changes. Equality and
/// hashing are based solely on `id` so that different snapshots of the same repo compare equal.
nonisolated public struct Repo: Identifiable, Equatable, Hashable, Sendable {
  /// Aggregated CI state for the repository.
  public enum State: UInt, Codable, Comparable, CaseIterable, Sendable {
    case unknown = 0
    case passing = 1
    case failing = 2
    case queued = 3
    case running = 4
    case partiallyFailing = 5
    /// No workflow runs exist or all workflows are disabled.
    case dormant = 6

    public static func < (lhs: State, rhs: State) -> Bool {
      lhs.sortOrder < rhs.sortOrder
    }

    /// Numeric priority used by the state-based sort; higher values appear first.
    var sortOrder: Int {
      switch self {
        case .unknown: 0
        case .dormant: 1
        case .passing: 2
        case .queued: 3
        case .running: 4
        case .partiallyFailing: 5
        case .failing: 6
      }
    }
  }

  /// Maps device identifiers to local filesystem paths for this repository.
  public typealias LocalPathDictionary = [String: String]

  /// A workflow and whether it should be included in the aggregate CI status.
  public struct WorkflowSelection: Codable, Hashable, Identifiable, Sendable {
    /// Stable GitHub workflow ID, if known. `nil` for workflows discovered by name only.
    public var workflowID: Int?
    /// Display name of the workflow.
    public var name: String
    /// Repository-relative path to the workflow YAML file.
    public var path: String
    /// Whether this workflow contributes to the aggregate state.
    public var enabled: Bool

    public init(workflowID: Int? = nil, name: String, path: String, enabled: Bool = true) {
      self.workflowID = workflowID
      self.name = name
      self.path = path
      self.enabled = enabled
    }

    /// Stable identifier: prefers the numeric workflow ID, falls back to the lowercased path.
    public var id: String {
      if let workflowID {
        return "id:\(workflowID)"
      }
      return "path:\(path.lowercased())"
    }

    /// Lookup key used when merging discovered workflows into the stored list; mirrors `id`.
    public var lookupKey: String { id }

    /// Workflow name derived from the YAML filename, stripping the extension.
    public var normalizedWorkflowName: String {
      let fileName = URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent
      if !fileName.isEmpty {
        return fileName
      }
      let lowered = name.lowercased()
      if lowered.hasSuffix(".yml") {
        return String(name.dropLast(4))
      }
      if lowered.hasSuffix(".yaml") {
        return String(name.dropLast(5))
      }
      return name
    }
  }

  /// Stable UUID string assigned at creation; used as the key in all stores.
  public let id: String
  /// Repository name on GitHub.
  public var name: String
  /// Organisation or user that owns the repository on GitHub.
  public var owner: String
  /// All known workflows for this repository; may include disabled entries.
  public var workflows: [WorkflowSelection]
  /// Branches to monitor; an empty list means the default branch.
  public var branches: [String]
  /// Current aggregated CI state, updated by the refresh layer.
  public var state: State
  /// Per-device local filesystem paths, keyed by device identifier.
  public var paths: LocalPathDictionary
  /// Timestamp of the most recent failed run, if any.
  public var lastFailed: Date?
  /// Timestamp of the most recent successful run, if any.
  public var lastSucceeded: Date?

  /// Creates a placeholder repo with default name and owner values.
  public init() {
    id = UUID().uuidString
    name = "SomeRepo"
    owner = "SomeOwner"
    workflows = []
    branches = []
    state = .unknown
    paths = [:]
  }

  /// Creates a repo with the supplied attributes.
  /// - Parameter workflow: Accepted for call-site compatibility; not persisted on this struct.
  public init(_ name: String, owner: String, workflow: String, id: String? = nil, state: State = .unknown, branches: [String] = []) {
    self.id = id ?? UUID().uuidString
    self.name = name
    self.owner = owner
    self.workflows = []
    self.branches = branches
    self.state = state
    self.paths = [:]
  }

  public func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
  }

  /// A `DictionaryDecoder` configured with sensible defaults for missing optional keys.
  public static var dictionaryDecoder: DictionaryDecoder {
    let decoder = DictionaryDecoder()
    let defaults: [String: Any] = [
      String(describing: LocalPathDictionary.self): LocalPathDictionary(),
      String(describing: [WorkflowSelection].self): [WorkflowSelection](),
    ]
    decoder.missingValueDecodingStrategy = .useDefault(defaults: defaults)
    return decoder
  }

  /// The subset of `workflows` that are currently enabled; empty when none are selected.
  public var enabledWorkflows: [WorkflowSelection] {
    workflows.filter(\.enabled)
  }

  /// Merges a freshly discovered workflow list into the stored list, preserving existing `enabled` flags.
  /// - Returns: `true` if the stored list changed and a model update is needed.
  @discardableResult mutating public func mergeDiscoveredWorkflows(_ discovered: [WorkflowSelection]) -> Bool {
    let existingByKey = Dictionary(uniqueKeysWithValues: workflows.map { ($0.lookupKey, $0) })
    let merged = discovered.map { workflow in
      var updated = workflow
      if let existing = existingByKey[workflow.lookupKey] {
        updated.enabled = existing.enabled
      } else {
        updated.enabled = true
      }
      return updated
    }

    guard merged != workflows else { return false }
    workflows = merged
    return true
  }

  /// Records the local path for `url` on `device` and stores a security-scoped bookmark.
  mutating public func remember(url: URL, forDevice device: String) {
    paths[device] = url.absoluteURL.path
    storeBookmark(for: url)
  }

  /// Returns the local URL for `device`, restoring a security-scoped bookmark if available.
  public func url(forDevice device: String?) -> URL? {
    guard let device = device, let path = paths[device] else { return nil }

    let url = URL(fileURLWithPath: path)
    return restoreBookmark(for: url)
  }


  /// Stores a security-scoped bookmark for `url` in `UserDefaults`.
  private func storeBookmark(for url: URL) {
    if let bookmark = url.secureBookmark() {
      UserDefaults.standard.set(bookmark, forKey: url.bookmarkKey)
    }
  }

  /// Resolves a previously stored security-scoped bookmark for `url`; returns `url` unchanged if none is found.
  private func restoreBookmark(for url: URL) -> URL {
    guard let data = UserDefaults.standard.data(forKey: url.bookmarkKey) else {
      return url
    }

    guard let resolved = URL.resolveSecureBookmark(data) else {
      return url
    }
    return resolved
  }

  /// Infers a `State` from the text content of a GitHub SVG badge.
  public func state(fromSVG svg: String) -> State {
    if svg.contains("failing") {
      return .failing
    } else if svg.contains("passing") {
      return .passing
    } else {
      return .unknown
    }
  }

  /// SF Symbol name appropriate for the current state, used in list and menu cells.
  public var badgeName: String {
    let name: String
    switch state {
      case .unknown: name = "questionmark.circle"
      case .dormant: name = "moon.zzz"
      case .failing: name = "xmark.circle"
      case .partiallyFailing: name = "xmark.circle"
      case .passing: name = "checkmark.circle"
      case .running: name = "arrow.triangle.2.circlepath"
      case .queued: name = "clock.arrow.circlepath"
    }
    return name
  }

  /// Destination page for a GitHub URL open action.
  public enum GithubLocation {
    /// The repository's main page.
    case repo
    /// The repository's Actions (workflow runs) page.
    case workflow
  }

  /// Constructs a `github.com` URL for the given location.
  public func githubURL(for location: GithubLocation = .workflow) -> URL {
    let suffix: String
    switch location {
      case .workflow: suffix = "/actions"
      default: suffix = ""
    }

    return URL(string: "https://github.com/\(owner)/\(name)\(suffix)")!
  }
}

extension Repo: Codable {
}

extension Repo: TypedDebugDescription {
  public var debugLabel: String {
    "\(owner)/\(name)".lowercased()
  }
}
