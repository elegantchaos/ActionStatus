// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Foundation
import SwiftUI

/// Service that controls which sheet is currently presented.
@Observable
public class SheetService {
  /// Currently displayed sheet, if any.
  public var showing: Sheet?

  /// Creates a sheet service.
  public init() {
  }

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

  /// Sheets presented by ActionStatus.
  public enum Sheet: Identifiable {
    case editRepo(Repo?)
    case preferences

    /// Stable identifier for the sheet content.
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

    return content.sheet(item: $service.showing) { _ in
      service.sheetView()
    }
  }
}

extension View {
  /// Attaches ActionStatus sheet presentation handling.
  func sheetHost() -> some View {
    modifier(SheetHostModifier())
  }
}
