// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import ActionStatusCore

class ViewState: ObservableObject {
    enum SheetType {
        case edit
        case compose
        case save
    }

    enum TextSize: Int {
        case automatic = 0
        case small = 1
        case medium = 2
        case large = 3
        case huge = 4
        
        var font: Font {
            switch self {
                case .automatic, .large: return .title
                case .huge: return .largeTitle
                case .medium: return .headline
                case .small: return .body
            }
        }
        
        var rowHeight: CGFloat { return 0 }
    }
    
    @Published var hasSheet = false
    @Published var sheetType: SheetType = .compose
    @Published var composingID: UUID? = nil
    @Published var isEditing: Bool = false
    @Published var selectedID: UUID? = nil
    @Published var repoTextSize: TextSize = .automatic

    let padding: CGFloat = 20
    let editIcon = "info.circle"
    let startEditingIcon = "lock.fill"
    let stopEditingIcon = "lock.open.fill"
    
    func showEditSheet(forRepoId id: UUID) {
        composingID = id
        sheetType = .edit
        hasSheet = true
    }

    func showComposeSheet(forRepoId id: UUID) {
        composingID = id
        sheetType = .compose
        hasSheet = true
    }
    
    func showSaveSheet() {
        sheetType = .save
        hasSheet = true
    }
    
    func hideSheet() {
        hasSheet = false
        composingID = nil
    }
    
    func addRepo(to model: Model) {
        let newRepo = model.addRepo()
        Application.shared.saveState()
        showEditSheet(forRepoId: newRepo.id)
        selectedID = newRepo.id
    }
}
