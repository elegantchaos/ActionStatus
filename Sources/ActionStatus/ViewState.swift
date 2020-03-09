// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import ActionStatusCore

class ViewState: ObservableObject {
    enum SheetType {
        case compose
        case save
    }

    @Published var hasSheet = false
    @Published var sheetType: SheetType = .compose
    @Published var composingID: UUID? = nil
    @Published var isEditing: Bool = false
    @Published var selectedID: UUID? = nil
    
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
        selectedID = newRepo.id
    }
}
