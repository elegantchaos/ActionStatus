// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import DictionaryCoding
import Foundation
import Logger
import Observation
import Runtime

public let modelChannel = Channel("com.elegantchaos.actionstatus.Model")


@Observable
public class Model {
  public typealias RepoList = [Repo]

  internal var store: ModelStore
  internal var items: [String: Repo]

  public var count: Int {
    items.count
  }


  public init(
    _ repos: [Repo],
    store: ModelStore = UbiquitousStore()
  ) {
    self.store = store
    store.synchronize()


    var index: [String: Repo] = [:]
    for repo in repos {
      let id = repo.id
      index[id] = repo
    }

    self.items = index
  }

  // MARK: Public

  public func load() {
    modelChannel.log("Loading from \(store)")
    var loadedRepos: [String: Repo] = [:]
    for repoID in store.index {
      if let repo = store.repo(forKey: repoID) {
        loadedRepos[repoID] = repo
      } else {
        modelChannel.log("Missing repo data for \(repoID).")
      }
    }
    items = loadedRepos


  }

  public func save() {
    modelChannel.log("Saving to \(store)")
    var repoIDs: [String] = []
    for (id, repo) in items {
      if store.store(repo, forKey: id) {
        repoIDs.append(id)
      }
    }

    let oldRepoIDs = store.index
    let removedIDs = Set(oldRepoIDs).subtracting(Set(repoIDs))
    for removedID in removedIDs {
      store.removeObject(forKey: removedID)
      modelChannel.log("Removed repo data for \(removedID)")
    }

    store.index = repoIDs
  }

  public func repo(withIdentifier id: String) -> Repo? {
    return items[id]
  }

  public func update(repoWithID id: String, state: Repo.State) {
    assert(Thread.isMainThread)
    if var repo = items[id] {
      modelChannel.log("Updated state of \(repo) to \(state)")
      repo.state = state
      switch state {
        case .passing: repo.lastSucceeded = Date()
        case .failing, .partiallyFailing: repo.lastFailed = Date()
        default: break
      }
      items[id] = repo
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

internal extension Model {
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
