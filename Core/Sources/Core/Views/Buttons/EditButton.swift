// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SheetController
import SwiftUI
import SwiftUIExtensions

struct EditButton: View {
    @EnvironmentObject var context: ViewContext
    @EnvironmentObject var sheetController: SheetController
    
    let repo: Repo
    
    var body: some View {
        Button(action: handleTapped) {
            SystemImage(context.editButtonIcon)
        }
        .accessibility(identifier: "editButton")
        .foregroundColor(.black)
    }

    func handleTapped() {
        sheetController.show() {
            EditView(repo: self.repo)
        }
    }
}

struct EditButton_Previews: PreviewProvider {
    static var previews: some View {
        let context = PreviewContext()
        return context.inject(into: EditButton(repo: context.testRepo))
    }
}
