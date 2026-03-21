// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Core
import Icons
import SwiftUI
import UniformTypeIdentifiers

/// Command that adds a new repository to the model,
/// and opens the edit sheet for it.
public struct AddRepoCommand<C: ModelServiceProvider & SheetServiceProvider>: CommandWithUI {
  public let id = "model.add"
  public let icon = Icon.addRepo
  public let shortcut: CommandShortcut? = .init("N", modifiers: [.command])

  let openSheet: Bool

  public init(openSheet: Bool = true) {
    self.openSheet = openSheet
  }

  public func perform(centre: C) async throws {
    if openSheet {
      // Keep the repo transient until the user confirms the add flow.
      centre.sheetService.showing = .addRepo(Repo())
    } else {
      _ = centre.modelService.addNewRepo()
    }
  }
}

/// Command that removes repositories from the model.
struct RemoveReposCommand<C: ModelServiceProvider>: CommandWithUI {
  let id = "model.remove"
  let icon = Icon.deleteRepo

  let ids: [String]

  func perform(centre: C) async throws {
    centre.modelService.remove(reposWithIDs: ids)
  }
}

/// Command that advances a repository through its debug states.
struct AdvanceStateCommand<C: ModelServiceProvider>: CommandWithUI {
  let id = "model.advance"
  let icon = Icon.advanceState

  let repo: Repo

  func perform(centre: C) async throws {
    if let newState = Repo.State(rawValue: (repo.state.rawValue + 1) % UInt(Repo.State.allCases.count)) {
      centre.modelService.updateState(newState, forRepoWithID: repo.id)
    }
  }
}

/// Command that imports repositories from local folders.
public struct AddLocalReposCommand<C: ModelServiceProvider>: ImporterCommand {
  public let id = "model.local"
  public let icon = Icon.addLocalRepo

  public var shortcut: CommandShortcut? { .init("O", modifiers: [.command]) }
  public var types: [UTType] { [.folder] }
  public var allowsMultipleSelection: Bool { true }

  public var state: ImporterCommandURLState = .unknown

  public init() {
  }
  public func perform(centre: C) async throws {
    switch state {
      case .chosen(let urls):
        centre.modelService.addLocalReposIn(urls)
      case .error(let error):
        commandChannel.log("Failed to import local repos: \(error)")
      case .unknown:
        commandChannel.log("No URLs chosen for local repo import")
    }
  }
}
