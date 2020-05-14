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
    
    var body: some View {
        Button(action: addRepo ) {
            SystemImage("plus.circle").padding(20).font(.headline)
        }
        .disabled(!viewState.isEditing)
        .opacity(viewState.isEditing ? 1.0 : 0.0)
    }
    
    func addRepo() {
        viewState.addRepo(to: model)
    }
}
#endif
