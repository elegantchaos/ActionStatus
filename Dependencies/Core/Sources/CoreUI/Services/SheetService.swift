// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CommandsUI
import Core
import Foundation
import Icons
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
        SheetView("ActionStatus Settings", shortTitle: "Settings", cancelAction: {}, doneAction: {}) {
          PreferencesForm()
        }
      default:
        EmptyView()
    }
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

struct ShowEditSheetCommand: CommandWithUI {
  let id = "sheet.add"
  let icon = Icon.editButtonIcon

  let repo: Repo?
  
  public init(repo: Repo? = nil) {
    self.repo = repo
  }
  
  public func perform(centre: Engine) async throws {
    centre.sheetService.showing = .editRepo(repo)
  }
}

struct ShowPreferencesSheetCommand: CommandWithUI {
  let id = "sheet.preferences"
  let icon = Icon.addIcon

  public func perform(centre: Engine) async throws {
    centre.sheetService.showing = .preferences
  }


}
