// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Foundation
import Keychain
import Logger
import Runtime
import SwiftUI

let githubChannel = Channel("com.elegantchaos.Github")

@Observable
@MainActor public class ModelService {
  @ObservationIgnored @AppStorage(.githubUser) var githubUser
  @ObservationIgnored @AppStorage(.githubServer) var githubServer
  @ObservationIgnored @AppStorage(.refreshInterval) var refreshInterval

  private let model: Model

  init(metadata: MetadataService) {
    model = metadata.device.platform.isSimulator || metadata.info.isUITestingBuild ? TestModel() : Model([])
  }

  public var count: Int { model.count }

  public var items: [UUID: Repo] { model.items }

  public func remove(reposWithIDs: [UUID]) {
    model.remove(reposWithIDs: reposWithIDs)
  }

  public func makeRandomisingRefreshController() -> RefreshController {
    return RandomisingRefreshController(model: model)
  }

  public func makeRefreshController() -> RefreshController? {
    guard !githubUser.isEmpty else {
      githubChannel.log("No GitHub account configured.")
      return nil
    }

    do {
      let token = try Keychain.default.password(for: githubUser, on: githubServer)
      guard !token.isEmpty else {
        githubChannel.log("No GitHub token configured.")
        return nil
      }

      let controller = OctoidRefreshController(model: model, token: token, apiServer: githubServer, refreshInterval: refreshInterval.rate)
      githubChannel.log("Using github refresh controller for \(githubUser)/\(githubServer)")
      return controller
    } catch {
      githubChannel.log("Couldn't get token: \(error).")
      return nil
    }
  }
  
  public func repos(sortedBy mode: SortMode) -> [Repo] {
    return mode.sort(model.items.values)
  }

  public func addRepo() {
    model.addRepo()
  }
  
  public func load() {
    model.load()
  }
  
  public func save() {
    model.save()
  }
  
  public func update(repo: Repo) {
    model.update(repo: repo)
  }
  
  public func update(repoWithID id: UUID, state: Repo.State) {
    model.update(repoWithID: id, state: state)
  }
  
  public func add(fromFolders urls: [URL]) {
    model.add(fromFolders: urls)
  }
}
