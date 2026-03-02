// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Observation
import Runtime
import SwiftUI

@MainActor struct PreviewHost: ApplicationHost {
  func modelDidChange() {
  }

  func settingsDidChange() {
  }

  let info = Bundle.main.runtimeInfo
  var refreshController: RefreshController? { return nil }
}

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

@Observable
public class ViewContext {
  public var settings = Settings()
  public var presentedSheet: PresentedSheet?
  public let info = AppInfo()
  public var host: Engine?
  public let padding: CGFloat = 10

  let linkIcon = "arrow.right.circle.fill"
  let preferencesIcon = "gearshape"
  let editButtonIcon = "ellipsis.circle"
  let deleteRepoIcon = "minus.circle"

  public init() {
  }

  var repoGridColumns: [GridItem] {
    let count: Int
    switch settings.displaySize {
      case .small: count = 4
      case .medium: count = 3
      default: count = 2
    }

    #if os(tvOS)
      return Array(repeating: .init(.flexible()), count: count)
    #else
      let cols = CGFloat(count)
      return [GridItem(.adaptive(minimum: 640 / cols, maximum: .infinity))]
    #endif
  }


}
