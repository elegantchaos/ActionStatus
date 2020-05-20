// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import SwiftUIExtensions
import ActionStatusCore

struct ToggleEditingButton: View {
    @EnvironmentObject var viewState: ViewState

    var body: some View {
        Button(action: toggleEditing) {
            SystemImage(viewState.isEditing ? viewState.stopEditingIcon : viewState.startEditingIcon).frame(width: 32, height: 32, alignment: .center)
        }.accessibility(identifier: "toggleEditing")
    }
    
    func toggleEditing() {
        viewState.isEditing.toggle()
    }
}


struct ToggleEditingButton_Previews: PreviewProvider {
    static var previews: some View {
        let context = PreviewContext()
        return context.inject(into:
            VStack {
                Text(context.state.isEditing ? "Editing Enabled" : "Editing Disabled")
                ToggleEditingButton()
            }
        )
    }
}

