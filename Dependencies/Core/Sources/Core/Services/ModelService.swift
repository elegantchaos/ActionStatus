// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Foundation
import Logger
import Observation

public let modelChannel = Channel("com.elegantchaos.actionstatus.Model")
public let githubChannel = Channel("com.elegantchaos.Github")

/// Provider of the shared model service used by commands.
@MainActor
public protocol ModelServiceProvider: CommandCentre {
  var modelService: ModelService { get }
}

@Observable
@MainActor
public final class ModelService {
  public typealias RepoList = [Repo]

  public enum Source {
    case cloud
    case resource(String)
  }

  @ObservationIgnored private var store: ModelStore
  @ObservationIgnored private let statusService: StatusService
  internal var items: [String: Repo]
  internal let deviceIdentifier: String?

  public init(
    _ repos: [Repo],
    statusService: StatusService,
    deviceIdentifier: String?,
    store: ModelStore? = nil
  ) {
    let resolvedStore = store ?? UbiquitousStore()
    self.store = resolvedStore
    self.statusService = statusService
    self.deviceIdentifier = deviceIdentifier
    self.items = .init(uniqueKeysWithValues: repos.map { ($0.id, $0) })

    statusService.connect(to: self)
    modelChannel.log("Initialised with \(resolvedStore)")
  }

  public convenience init(statusService: StatusService, deviceIdentifier: String?, source: Source) {
    let store: ModelStore
    switch source {
      case .cloud:
        store = UbiquitousStore()
      case .resource(let name):
        store = BundleStore(key: name)
    }

    self.init([], statusService: statusService, deviceIdentifier: deviceIdentifier, store: store)
  }
  
  public func startup() async {
    await store.onChange { [weak self] newValues in
      self?.load(newValues: newValues)
    }
    modelChannel.log("Started")
  }

  public var count: Int {
    items.count
  }

  /// Cache our own copy of the items from the store.
  private func load(newValues: ModelStore.Values) {
    items = newValues
  }

  /// Return a repo from our cache.
  public func repo(withIdentifier id: String) -> Repo? {
    items[id]
  }

  public func updateState(_ state: Repo.State, forRepoWithID id: String) {
    if var repo = items[id] {
      modelChannel.log("\(repo) changed to \(state)")
      repo.state = state
      switch state {
        case .passing:
          repo.lastSucceeded = Date()
        case .failing, .partiallyFailing:
          repo.lastFailed = Date()
        default:
          break
      }
      update(repo: repo)
    } else {
      modelChannel.log("Unknown repo \(id) changed to \(state)")
    }
  }

  public func update(repo: Repo) {
    let item = items[repo.id]
    let shouldUpdate: Bool
    if let existing = item, repo != existing {
      shouldUpdate = true
    } else {
      shouldUpdate = item == nil
    }

    if shouldUpdate {
      modelChannel.log(items[repo.id] == nil ? "Added \(repo)" : "Updated \(repo)")
      items[repo.id] = repo
      store.set(repo, forKey: repo.id)
    }
  }

  public func remember(url: URL, forDevice device: String, inRepo repo: Repo) {
    if var repo = items[repo.id] {
      repo.remember(url: url, forDevice: device)
      update(repo: repo)
    }
  }

  /// Add a new repo with default values, and return it.
  @discardableResult public func addNewRepo() -> Repo {
    let repo = Repo()
    items[repo.id] = repo
    store.set(repo, forKey: repo.id)
    return repo
  }

  @discardableResult
  public func addRemoteRepo(name: String, owner: String) -> Repo {
    let repo = Repo(name, owner: owner, workflow: "Tests")
    items[repo.id] = repo
    store.set(repo, forKey: repo.id)
    return repo
  }

  public func addLocalReposIn(_ urls: [URL]) {
    if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
      let fileManager = FileManager.default
      for url in urls {
        if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: []) {
          while let repositoryURL = enumerator.nextObject() as? URL {
            if repositoryURL.lastPathComponent == ".git" {
              addLocalRepoIn(repositoryURL, detector: detector)
            }
          }
        }
      }
    }
  }

  public func remove(reposWithIDs ids: [String]) {
    for id in ids {
      items.removeValue(forKey: id)
      store.remove(forKey: id)
    }
  }
}

internal extension ModelService {
  func addLocalRepoIn(_ localGitFolderURL: URL, detector: NSDataDetector) {
    let containerURL = localGitFolderURL.deletingLastPathComponent()
    let containerName = containerURL.lastPathComponent
    if let config = try? String(contentsOf: localGitFolderURL.appendingPathComponent("config"), encoding: .utf8) {
      let tweaked = config.replacingOccurrences(of: "git@github.com:", with: "https://github.com/")
      let range = NSRange(location: 0, length: tweaked.count)
      for result in detector.matches(in: tweaked, options: [], range: range) {
        if let url = result.url, url.scheme == "https", url.host == "github.com" {
          let name = url.deletingPathExtension().lastPathComponent
          let owner = url.deletingLastPathComponent().lastPathComponent
          var repo = items.first(where: { $0.value.name == name && $0.value.owner == owner })?.value
          if repo == nil {
            repo = addRemoteRepo(name: name, owner: owner)
          }

          if repo?.name == containerName, let device = deviceIdentifier, let repo {
            remember(url: containerURL, forDevice: device, inRepo: repo)
            modelChannel.log("Local path for \(repo.name) on machine \(device) is \(localGitFolderURL).")
          }
        }
      }
    }
  }
}

extension ModelService: TypedDebugDescription {
  public var debugLabel: String { "store: \(store)" }
}
