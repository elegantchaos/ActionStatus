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

extension Engine: ModelServiceProvider {

}

struct AddRepoCommand<C: ModelServiceProvider>: CommandWithUI {
  let id = "model.add"
  let icon = Icon.addIcon

  func perform(centre: C) async throws {
    centre.modelService.addRepo()
  }
}

struct RemoveReposCommand<C: ModelServiceProvider>: CommandWithUI {
  let id = "model.remove"
  let icon = Icon.deleteRepoIcon

  let ids: [String]
  
  func perform(centre: C) async throws {
    centre.modelService.remove(reposWithIDs: ids)
  }
}

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
