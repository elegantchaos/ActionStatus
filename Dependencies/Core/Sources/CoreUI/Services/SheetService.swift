// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Foundation
import SwiftUI

/// Service that controls which sheet is currently presented.
@Observable
public final class SheetService {
  /// Currently displayed sheet, if any.
  public var showing: Sheet?

  /// Creates a sheet service.
  public init() {
  }

  /// Builds the view for the supplied sheet type.
  @ViewBuilder
  func sheetView(for sheet: Sheet) -> some View {
    switch sheet {
      case .editRepo(let repo):
        EditRepoView(repo: repo, adding: false)
      case .addRepo(let repo):
        EditRepoView(repo: repo, adding: true)
      case .preferences:
        SheetView(
          "ActionStatus Settings",
          shortTitle: "Settings",
          cancelAction: dismiss,
          doneAction: dismiss
        ) {
          PreferencesForm()
        }
    }
  }

  /// Clears the currently shown sheet.
  func dismiss() {
    showing = nil
  }

  /// Sheets presented by ActionStatus.
  public enum Sheet: Identifiable {
    /// Edit an existing repo.
    case editRepo(Repo)
    
    /// Adding a new repo.
    case addRepo(Repo)
    
    /// The app preferences form.
    case preferences

    /// Stable identifier for the sheet content.
    public var id: String {
      switch self {
        case .editRepo(let repo):
          return "edit-\(repo.id)"
        case .addRepo:
          return "edit-new"
        case .preferences:
          return "preferences"
      }
    }
  }
}

/// View modifier that presents ActionStatus sheets using `SheetService`.
struct SheetHostModifier: ViewModifier {
  @Environment(SheetService.self) var sheetService

  func body(content: Content) -> some View {
    @Bindable var service = sheetService

    return content.sheet(item: $service.showing) { sheet in
      service.sheetView(for: sheet)
    }
  }
}

extension View {
  /// Attaches ActionStatus sheet presentation handling.
  func sheetHost() -> some View {
    modifier(SheetHostModifier())
  }
}
