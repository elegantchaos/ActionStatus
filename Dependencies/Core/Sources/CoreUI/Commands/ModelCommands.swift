// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Core
import Icons

/// Command that adds a new repository to the model.
struct AddRepoCommand<C: ModelServiceProvider>: CommandWithUI {
  let id = "model.add"
  let icon = Icon.addIcon

  func perform(centre: C) async throws {
    centre.modelService.addNewRepo()
  }
}

/// Command that removes repositories from the model.
struct RemoveReposCommand<C: ModelServiceProvider>: CommandWithUI {
  let id = "model.remove"
  let icon = Icon.deleteRepoIcon

  let ids: [String]

  func perform(centre: C) async throws {
    centre.modelService.remove(reposWithIDs: ids)
  }
}

/// Command that advances a repository through its debug states.
struct AdvanceStateCommand<C: ModelServiceProvider>: CommandWithUI {
  let id = "model.advance"
  let icon = Icon.advanceStateIcon

  let repo: Repo

  func perform(centre: C) async throws {
    if let newState = Repo.State(rawValue: (repo.state.rawValue + 1) % UInt(Repo.State.allCases.count)) {
      centre.modelService.updateState(newState, forRepoWithID: repo.id)
    }
  }
}

/// Command that imports repositories from local folders.
public struct AddLocalReposCommand<C: LocalRepoImportingProvider>: CommandWithUI {
  public let id = "model.local"
  public let icon = Icon.addLocalIcon

  public var shortcut: CommandShortcut? { .init("O", modifiers: [.command]) }

  public init() {
  }

  public func perform(centre: C) async throws {
    centre.addLocalRepos()
  }
}
