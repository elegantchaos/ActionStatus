// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Core
import DictionaryCoding
import Foundation
import Logger
import Observation
import Runtime

public let modelChannel = Channel("com.elegantchaos.actionstatus.Model")
let githubChannel = Channel("com.elegantchaos.Github")

public protocol ModelServiceProvider: CommandCentre {
  var modelService: ModelService { get }
}

@Observable
@MainActor public class ModelService {
  public typealias RepoList = [Repo]

  enum Source {
    case cloud
    case resource(String)
  }

  @ObservationIgnored private var store: ModelStore
  @ObservationIgnored private let statusService: StatusService

  internal var items: [String: Repo]

  public init(
    _ repos: [Repo],
    statusService: StatusService,
    store: ModelStore? = nil
  ) {
    self.store = store ?? UbiquitousStore()
    self.statusService = statusService
    self.items = .init(uniqueKeysWithValues: repos.map { ($0.id, $0) })
                      
    statusService.connect(to: self)
    modelChannel.log("Initialised with \(store!)")
  }

  public func startup() async {
    await store.onChange { newValues in
      await self.load(newValues: newValues)
    }
    modelChannel.log("Started")
  }
  
  convenience init(statusService: StatusService, source: Source) {
    let store: ModelStore
    switch source {
      case .cloud: store = UbiquitousStore()
      case .resource(let name): store = BundleStore(key: name)
    }

    self.init([], statusService: statusService, store: store)
  }

  // MARK: Public

  public var count: Int {
    items.count
  }

  /// Cache our own copy of the items from the store.
  private func load(newValues: ModelStore.Values) {
    items = newValues
  }
  
  /// Return a repo from our cache.
  public func repo(withIdentifier id: String) -> Repo? {
    return items[id]
  }

  public func updateState(_ state: Repo.State, forRepoWithID id: String, ) {
    assert(Thread.isMainThread)
    if var repo = items[id] {
      modelChannel.log("\(repo) changed to \(state)")
      repo.state = state
      switch state {
        case .passing: repo.lastSucceeded = Date()
        case .failing, .partiallyFailing: repo.lastFailed = Date()
        default: break
      }
      update(repo: repo)
    } else {
      modelChannel.log("Unknown repo \(id) changed to \(state)")
    }
  }

  public func update(repo: Repo) {
    assert(Thread.isMainThread)
    let item = items[repo.id]
    let update: Bool
    if let existing = item, repo != existing {
      update = true
    } else {
      update = item == nil
    }

    if update {
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

  @discardableResult public func addRepo() -> Repo {
    let repo = Repo()
    items[repo.id] = repo

    return repo
  }

  @discardableResult public func addRepo(name: String, owner: String) -> Repo {
    let repo = Repo(name, owner: owner, workflow: "Tests")
    items[repo.id] = repo

    return repo
  }

  public func add(fromFolders urls: [URL]) {
    if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
      let fm = FileManager.default
      for url in urls {
        if let enumerator = fm.enumerator(at: url, includingPropertiesForKeys: []) {
          while let url = enumerator.nextObject() as? URL {
            if url.lastPathComponent == ".git" {
              add(fromGitRepo: url, detector: detector)
            }
          }
        }
      }
    }
  }

  public func remove(reposWithIDs: [String]) {
    for id in reposWithIDs {
      items.removeValue(forKey: id)
    }
  }
}

// MARK: Internal

internal extension ModelService {
  func add(fromGitRepo localGitFolderURL: URL, detector: NSDataDetector) {
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
            repo = addRepo(name: name, owner: owner)
          }

          if repo?.name == containerName, let identifier = Device().identifier, let repo = repo {
            remember(url: containerURL, forDevice: identifier, inRepo: repo)
            modelChannel.log("Local path for \(repo.name) on machine \(identifier) is \(localGitFolderURL).")
          }
        }
      }
    }
  }

}
