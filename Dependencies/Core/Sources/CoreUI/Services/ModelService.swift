// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Core
import Foundation
import Icons
import Keychain
import Logger
import Runtime
import SwiftUI

let githubChannel = Channel("com.elegantchaos.Github")

public protocol ModelServiceProvider: CommandCentre {
  var modelService: ModelService { get }
}

@Observable
@MainActor public class ModelService {
  @ObservationIgnored @AppStorage(.githubUser) var githubUser
  @ObservationIgnored @AppStorage(.githubServer) var githubServer
  @ObservationIgnored @AppStorage(.refreshInterval) var refreshInterval
  @ObservationIgnored @AppStorage(.sortModeKey) var sortMode

  private let model: Model
  private let statusService: StatusService

  init(statusService: StatusService, useTestModel: Bool) {
    self.statusService = statusService
    self.model = useTestModel ? TestModel() : Model([])
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

  fileprivate func addRepo() {
    model.addRepo()
    modelChanged()
  }

  public func load() {
    model.load()
  }

  public func save() {
    model.save()
  }

  public func update(repo: Repo) {
    model.update(repo: repo)
    modelChanged()
  }

  public func update(repoWithID id: UUID, state: Repo.State) {
    model.update(repoWithID: id, state: state)
    modelChanged()
  }

  public func add(fromFolders urls: [URL]) {
    model.add(fromFolders: urls)
    modelChanged()
  }

  func modelChanged() {
    let sorted = sortMode.sort(model.items.values)
    statusService.update(with: sorted)
    save()
  }
}

extension Engine: ModelServiceProvider {
  
}

struct AddRepoCommand<C: ModelServiceProvider>: CommandWithUI {
  let id = "model.add"
  let icon = Icon.addIcon

  func perform(centre: C) async throws {
    centre.modelService.addRepo()
  }


}
