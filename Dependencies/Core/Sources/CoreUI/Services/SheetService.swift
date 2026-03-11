// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Foundation
import SwiftUI

@Observable
public class SheetService {
  public var showing: Sheet?

  @ViewBuilder
  func sheetView() -> some View {
    switch showing {
      case .editRepo(let repo):
        EditView(repo: repo)
      case .preferences:
        SheetView(
          "ActionStatus Settings",
          shortTitle: "Settings",
          cancelAction: dismiss,
          doneAction: dismiss
        ) {
          PreferencesForm()
        }
      default:
        EmptyView()
    }
  }

  func dismiss() {
    showing = nil
  }


  public enum Sheet: Identifiable {
    case editRepo(Repo?)
    case preferences

    public var id: String {
      switch self {
        case .editRepo(let repo):
          if let repo {
            return "edit-\(repo.id)"
          }
          return "edit-new"
        case .preferences:
          return "preferences"
      }
    }
  }

}

struct SheetHostModifier: ViewModifier {
  @Environment(SheetService.self) var sheetService

  func body(content: Content) -> some View {
    @Bindable var service = sheetService

    return
      content
      .sheet(item: $service.showing) { sheet in
        service.sheetView()
      }
  }
}

extension View {
  func sheetHost() -> some View {
    modifier(SheetHostModifier())
  }
}
