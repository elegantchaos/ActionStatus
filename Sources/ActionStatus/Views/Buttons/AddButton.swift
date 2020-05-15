// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import SwiftUIExtensions
import ActionStatusCore

#if canImport(UIKit)
struct AddButton: View {
    @EnvironmentObject var viewState: ViewState
    @EnvironmentObject var model: Model
    @EnvironmentObject var sheetController: SheetController
    
    var body: some View {
        Button(action: addRepo ) {
            Text("Add")
        }
        .disabled(!viewState.isEditing)
        .opacity(viewState.isEditing ? 1.0 : 0.0)
        .animation(.easeInOut)
    }
    
    func addRepo() {
        let repo = viewState.addRepo(to: model)
        sheetController.show() {
            EditView(repoID: repo.id)
        }
    }
}
#endif

struct AddButton_Previews: PreviewProvider {
    static var previews: some View {
        PreviewContext().inject(into: AddButton())
    }
}

