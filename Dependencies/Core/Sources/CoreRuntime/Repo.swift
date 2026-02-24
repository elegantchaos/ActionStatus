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

extension Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool where Self: RawRepresentable, Self.RawValue: Comparable {
    lhs.rawValue < rhs.rawValue
  }
}

public struct Repo: Identifiable, Equatable, Hashable {
  public enum State: UInt, Codable, Comparable, CaseIterable {
    case unknown = 0
    case passing = 1
    case failing = 2
    case queued = 3
    case running = 4
  }

  public typealias LocalPathDictionary = [String: String]

  public let id: UUID
  public var name: String
  public var owner: String
  public var workflow: String
  public var branches: [String]
  public var state: State
  public var paths: LocalPathDictionary
  public var lastFailed: Date?
  public var lastSucceeded: Date?

  public init(defaultName: String = "", defaultOwner: String = "", defaultWorkflow: String = "Tests", defaultBranches: [String] = []) {
    id = UUID()
    name = defaultName
    owner = defaultOwner
    workflow = defaultWorkflow
    branches = defaultBranches
    state = .unknown
    paths = [:]
  }

  public init(_ name: String, owner: String, workflow: String, id: UUID? = nil, state: State = .unknown, branches: [String] = []) {
    self.id = id ?? UUID()
    self.name = name
    self.owner = owner
    self.workflow = workflow
    self.branches = branches
    self.state = state
    self.paths = [:]
  }

  public func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
  }

  public func identical(to other: Repo) -> Bool {
    return id == other.id
      && name == other.name
      && owner == other.owner
      && workflow == other.workflow
      && branches == other.branches
      && state == other.state
      && paths == other.paths
      && lastFailed == other.lastFailed
      && lastSucceeded == other.lastSucceeded
  }

  public static var dictionaryDecoder: DictionaryDecoder {
    let decoder = DictionaryDecoder()
    let defaults: [String: Any] = [
      String(describing: LocalPathDictionary.self): LocalPathDictionary()
    ]
    decoder.missingValueDecodingStrategy = .useDefault(defaults: defaults)
    return decoder


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
      case .failing: name = "xmark.circle"
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
      case .workflow: suffix = "/actions?query=workflow%3A\(workflow)"
      case .badge(let branch):
        let query = branch.isEmpty ? "" : "?branch=\(branch)"
        suffix = "/workflows/\(workflow)/badge.svg\(query)"

      default: suffix = ""
    }

    return URL(string: "https://github.com/\(owner)/\(name)\(suffix)")!
  }
}

extension Repo: Codable {
}
