// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import SwiftUIExtensions
import ActionStatusCore

struct EditButton: View {
    @EnvironmentObject var viewState: ViewState
    let repoID: UUID
    
    var body: some View {
        Button(action: edit) {
            SystemImage(viewState.editIcon)
                .foregroundColor(Color.accentColor)
        }
    }

    func edit() {
        viewState.showEditSheet(forRepoId: repoID)
    }
}

struct EditButton_Previews: PreviewProvider {
    static var previews: some View {
        let context = PreviewContext()
        return context.inject(into: EditButton(repoID: context.repos.first!.id))
    }
}
