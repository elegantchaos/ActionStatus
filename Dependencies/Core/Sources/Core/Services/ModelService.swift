// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Foundation
import Logger
import Observation
import Runtime

/// Logger channel for model-layer events.
public let modelChannel = Channel("com.elegantchaos.actionstatus.Model")
/// Logger channel for GitHub-specific events in the model layer.
public let githubChannel = Channel("com.elegantchaos.Github")

/// Provider of the shared model service used by commands.
@MainActor
public protocol ModelServiceProvider: CommandCentre {
  var modelService: ModelService { get }
}

/// Manages the in-memory repository list and its backing store.
///
/// `ModelService` is the single point of truth for repository data. It owns an
/// `@Observable` items dictionary that drives all SwiftUI views. All mutations
/// (add, remove, update state) flow through this class so the backing
/// `ModelStore` (iCloud key-value or bundle JSON) stays in sync.
///
/// The class is `@MainActor`-bound and `@Observable` so SwiftUI observation works
/// without any manual `objectWillChange` calls. Status projection (sorted lists,
/// counts) is handled by `StatusService`, which the application layer connects
/// via `StatusService.connect(to:)` after both services are created.
@Observable
@MainActor
public final class ModelService {
  /// Convenience alias for an ordered list of repos.
  public typealias RepoList = [Repo]

  /// The origin of the model data.
  public enum Source {
    /// Backed by `NSUbiquitousKeyValueStore`.
    case cloud
    /// Backed by a JSON file in the app bundle with the given resource name.
    case resource(String)
  }

  @ObservationIgnored private var store: ModelStore

  internal var items: [String: Repo]
  internal let deviceIdentifier: String?

  /// Creates a model service pre-seeded with `repos`, using `store` as the backing store.
  public init(
    _ repos: [Repo],
    deviceIdentifier: String?,
    store: ModelStore? = nil
  ) {
    let resolvedStore = store ?? UbiquitousStore()
    self.store = resolvedStore
    self.deviceIdentifier = deviceIdentifier
    self.items = .init(uniqueKeysWithValues: repos.map { ($0.id, $0) })
    modelChannel.log("Initialised with \(resolvedStore)")
  }

  /// Creates a model service with an empty initial list,
  /// using the default store and device identifier for the runtime.
  public convenience init(runtime: Runtime = .shared) {
    let store: ModelStore
    switch runtime.modelSource {
      case .cloud:
        store = UbiquitousStore()
      case .resource(let name):
        store = BundleStore(key: name)
    }

    self.init([], deviceIdentifier: runtime.deviceIdentifier, store: store)
  }

  /// The number of repositories currently in the model.
  public var count: Int {
    items.count
  }

  /// Begins observing the backing store for external changes and loads the initial snapshot.
  public func startup() async {
    await store.onChange { [weak self] newValues in
      self?.load(newValues: newValues)
    }
    modelChannel.log("Started")
  }

  /// Returns the repo stored under `id`, or `nil` if not present.
  public func repo(withIdentifier id: String) -> Repo? {
    items[id]
  }

  /// Updates the state for the given repo and records the timestamp if applicable.
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

  /// Persists `repo` to the store; skips the write if the value is unchanged.
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

  /// Records the local path for `url` on `device` inside the stored repo value.
  public func remember(url: URL, forDevice device: String, inRepo repo: Repo) {
    if var repo = items[repo.id] {
      repo.remember(url: url, forDevice: device)
      update(repo: repo)
    }
  }

  /// Adds a new repo with default placeholder values and returns it.
  @discardableResult public func addNewRepo() -> Repo {
    let repo = Repo()
    items[repo.id] = repo
    store.set(repo, forKey: repo.id)
    return repo
  }

  /// Creates and persists a new repo for a remote GitHub repository.
  @discardableResult
  public func addRemoteRepo(name: String, owner: String) -> Repo {
    let repo = Repo(name, owner: owner, workflow: "Tests")
    items[repo.id] = repo
    store.set(repo, forKey: repo.id)
    return repo
  }

  /// Recursively searches `urls` for `.git` directories and adds matching GitHub repos.
  public func addLocalReposIn(_ urls: [URL]) {
    if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
      let fileManager = FileManager.default
      for url in urls {
        modelChannel.log("Looking for local repos in \(url)")
        if url.startAccessingSecurityScopedResource() {
          if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: []) {
            while let repositoryURL = enumerator.nextObject() as? URL {
              if repositoryURL.lastPathComponent == ".git" {
                addLocalRepoIn(repositoryURL, detector: detector)
              }
            }
          }
          url.stopAccessingSecurityScopedResource()
        }
      }
    }
  }

  /// Removes the repos identified by `ids` from both the cache and the backing store.
  public func remove(reposWithIDs ids: [String]) {
    for id in ids {
      items.removeValue(forKey: id)
      store.remove(forKey: id)
    }
  }

  /// Replaces the in-memory items with a fresh snapshot from the store.
  private func load(newValues: ModelStore.Values) {
    items = newValues
  }
}

internal extension ModelService {
  /// Parses the git config at `localGitFolderURL` for GitHub remote URLs and registers matching repos.
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
