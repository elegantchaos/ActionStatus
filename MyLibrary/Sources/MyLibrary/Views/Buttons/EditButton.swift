// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SheetController
import SwiftUI
import SwiftUIExtensions

struct EditButton: View {
    @EnvironmentObject var viewState: ViewState
    @EnvironmentObject var sheetController: SheetController
    
    let repoID: UUID
    
    var body: some View {
        Button(action: edit) {
            SystemImage(viewState.editIcon)
                .foregroundColor(Color.accentColor)
        }.accessibility(identifier: "editButton")
    }

    func edit() {
        sheetController.show() {
            EditView(repoID: self.repoID)
        }
    }
}

struct EditButton_Previews: PreviewProvider {
    static var previews: some View {
        let context = PreviewContext()
        return context.inject(into: EditButton(repoID: context.testRepo.id))
    }
}
