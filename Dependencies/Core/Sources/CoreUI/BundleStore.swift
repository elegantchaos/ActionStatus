// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Foundation

public class BundleStore: ModelStore {
  public var index: [String]
  var repos: [String: Repo]

  init(key: String, bundle: Bundle = Bundle.main) {
    guard let url = bundle.url(forResource: key, withExtension: "json") else {
      fatalError("Missing RepoResource from \(key) in \(bundle)")
    }

    do {
      let data = try Data(contentsOf: url)
      let decoder = JSONDecoder()
      let decoded = try decoder.decode([String: Repo].self, from: data)
      index = Array(decoded.keys)
      repos = decoded
    } catch {
      fatalError("Failed to decode RepoResource data \(key) in \(bundle)")
    }
  }

  public func synchronize() -> Bool {
    return true
  }

  public func repo(forKey key: String) -> Core.Repo? {
    repos[key]
  }

  public func store(_ repo: Core.Repo, forKey key: String) -> Bool {
    repos[key] = repo
    return true
  }

  public func removeObject(forKey key: String) {
    repos.removeValue(forKey: key)

  }


}
