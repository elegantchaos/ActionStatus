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

  let linkIcon = "arrow.right.circle.fill"
  let preferencesIcon = "gearshape"
  let editButtonIcon = "ellipsis.circle"
  let deleteRepoIcon = "minus.circle"

  public init(host: ApplicationHost) {
    self.host = host
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
