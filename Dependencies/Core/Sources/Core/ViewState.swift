// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Bundles
import Core
import SwiftUI

struct PreviewHost: ApplicationHost {
  let info = BundleInfo(for: Bundle.main)
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

public class ViewContext: ObservableObject {
  @Published public var settings = Settings()
  @Published public var presentedSheet: PresentedSheet?

  public let host: ApplicationHost
  public let padding: CGFloat = 10
  public let spacing: CGFloat = {
    #if os(tvOS)
      640
    #else
      256
    #endif
  }()

  let linkIcon = "arrow.right.circle.fill"
  let startEditingIcon = "lock.fill"
  let stopEditingIcon = "lock.open.fill"
  let preferencesIcon = "gearshape"
  let editButtonIcon = "ellipsis.circle"
  let deleteRepoIcon = "minus.circle"
  let addRepoIcon = "plus.circle"

  public init(host: ApplicationHost) {
    self.host = host
  }

  @discardableResult func addRepo(to model: Model) -> Repo {
    let newRepo = model.addRepo()
    host.saveState()
    settings.selectedID = newRepo.id
    return newRepo
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
