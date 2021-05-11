// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SheetController
import SwiftUI
import SwiftUIExtensions

public struct AddButton: View {
    @EnvironmentObject var viewState: ViewState
    @EnvironmentObject var model: Model
    @EnvironmentObject var sheetController: SheetController
    
    public init() {
    }
    
    public var body: some View {
        Button(action: addRepo ) {
            Text("Add")
//            Image(systemName: viewState.addRepoIcon)
        }
        .accessibility(identifier: "addButton")
        .foregroundColor(.black)
        .animation(.easeInOut)
    }
    
    func addRepo() {
        sheetController.show() {
            EditView(repo: nil)
        }
    }
}

struct AddButton_Previews: PreviewProvider {
    static var previews: some View {
        PreviewContext().inject(into: AddButton())
    }
}

