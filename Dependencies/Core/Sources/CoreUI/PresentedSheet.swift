// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Observation
import Runtime
import SwiftUI

public enum PresentedSheet: Identifiable {
  case editRepo(Repo?)
  case preferences

  public var id: String {
    switch self {
      case .editRepo(let repo):
        if let repo {
          return "edit-\(repo.id.uuidString)"
        }
        return "edit-new"
      case .preferences:
        return "preferences"
    }
  }
}
