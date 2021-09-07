// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/05/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SheetController
import SwiftUI
import SwiftUIExtensions

struct GenerateWorkflowButton: View {
    @EnvironmentObject var context: ViewContext
    @EnvironmentObject var sheetController: SheetController
    
    let repo: Repo
    
    var body: some View {
        Button(action: handleTapped) {
            SystemImage(context.generateButtonIcon)
        }
        .accessibility(identifier: "generateButton")
    }

    func handleTapped() {
        sheetController.show() {
            GenerateView(repoID: repo.id)
        }
    }
}

struct GenerateButton_Previews: PreviewProvider {
    static var previews: some View {
        let context = PreviewContext()
        return context.inject(into: GenerateWorkflowButton(repo: context.testRepo))
    }
}


