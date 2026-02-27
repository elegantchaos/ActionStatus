// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import DictionaryCoding
import Files
import Foundation

private extension URL {
  var bookmarkKey: String { "bookmark:\(absoluteURL.path)" }
}

public struct Repo: Identifiable, Equatable, Hashable {
  public enum State: UInt, Codable, Comparable, CaseIterable {
    case unknown = 0
    case passing = 1
    case failing = 2
    case queued = 3
    case running = 4
    case partiallyFailing = 5
    case dormant = 6

    public static func < (lhs: State, rhs: State) -> Bool {
      lhs.sortOrder < rhs.sortOrder
    }

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

  public typealias LocalPathDictionary = [String: String]

  public struct WorkflowSelection: Codable, Hashable, Identifiable {
    public var workflowID: Int?
    public var name: String
    public var path: String
    public var enabled: Bool

    public init(workflowID: Int? = nil, name: String, path: String, enabled: Bool = true) {
      self.workflowID = workflowID
      self.name = name
      self.path = path
      self.enabled = enabled
    }

    public var id: String {
      if let workflowID {
        return "id:\(workflowID)"
      }
      return "path:\(path.lowercased())"
    }

    public var lookupKey: String {
      if let workflowID {
        return "id:\(workflowID)"
      }
      return "path:\(path.lowercased())"
    }

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

  public let id: UUID
  public var name: String
  public var owner: String
  public var workflow: String
  public var workflows: [WorkflowSelection]
  public var branches: [String]
  public var state: State
  public var paths: LocalPathDictionary
  public var lastFailed: Date?
  public var lastSucceeded: Date?

  public init() {
    id = UUID()
    name = "SomeRepo"
    owner = "someone"
    workflow = "Tests"
    workflows = []
    branches = []
    state = .unknown
    paths = [:]
  }

  public init(_ name: String, owner: String, workflow: String, id: UUID? = nil, state: State = .unknown, branches: [String] = []) {
    self.id = id ?? UUID()
    self.name = name
    self.owner = owner
    self.workflow = workflow
    self.workflows = []
    self.branches = branches
    self.state = state
    self.paths = [:]
  }

  public func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
  }

  public static var dictionaryDecoder: DictionaryDecoder {
    let decoder = DictionaryDecoder()
    let defaults: [String: Any] = [
      String(describing: LocalPathDictionary.self): LocalPathDictionary(),
      String(describing: [WorkflowSelection].self): [WorkflowSelection](),
    ]
    decoder.missingValueDecodingStrategy = .useDefault(defaults: defaults)
    return decoder


  }

  public var enabledWorkflows: [WorkflowSelection] {
    let selected = workflows.filter(\.enabled)
    if !selected.isEmpty {
      return selected
    }

    let trimmedLegacy = workflow.trimmingCharacters(in: .whitespacesAndNewlines)
    if workflows.isEmpty, !trimmedLegacy.isEmpty {
      return [WorkflowSelection(name: trimmedLegacy, path: ".github/workflows/\(trimmedLegacy).yml")]
    }

    return []
  }

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

  mutating public func remember(url: URL, forDevice device: String) {
    paths[device] = url.absoluteURL.path
    storeBookmark(for: url)
  }

  public func url(forDevice device: String?) -> URL? {
    guard let device = device, let path = paths[device] else { return nil }

    let url = URL(fileURLWithPath: path)
    return restoreBookmark(for: url)
  }


  func storeBookmark(for url: URL) {
    if let bookmark = url.secureBookmark() {
      UserDefaults.standard.set(bookmark, forKey: url.bookmarkKey)
    }
  }

  func restoreBookmark(for url: URL) -> URL {
    guard let data = UserDefaults.standard.data(forKey: url.bookmarkKey) else {
      return url
    }

    guard let resolved = URL.resolveSecureBookmark(data) else {
      return url
    }
    return resolved
  }

  public func state(fromSVG svg: String) -> State {
    if svg.contains("failing") {
      return .failing
    } else if svg.contains("passing") {
      return .passing
    } else {
      return .unknown
    }
  }

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

  public enum GithubLocation {
    case repo
    case workflow
    case badge(String)
  }

  public func githubURL(for location: GithubLocation = .workflow) -> URL {
    let suffix: String
    switch location {
      case .workflow: suffix = "/actions"
      case .badge(let branch):
        let query = branch.isEmpty ? "" : "?branch=\(branch)"
        let workflowName = enabledWorkflows.first?.normalizedWorkflowName ?? workflow
        suffix = "/workflows/\(workflowName)/badge.svg\(query)"

      default: suffix = ""
    }

    return URL(string: "https://github.com/\(owner)/\(name)\(suffix)")!
  }
}

extension Repo: Codable {
}
