// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import SwiftUIExtensions

public struct ToggleEditingButton: View {
    @EnvironmentObject var viewState: ViewState

    public init() {
    }
    
    public var body: some View {
        HStack {
            Button(action: toggleEditing) {
                Text(viewState.settings.isEditing ? "Done" : "Edit")
//                Image(systemName: viewState.settings.isEditing ? viewState.stopEditingIcon : viewState.startEditingIcon)
            }
            .accentColor(.black)
            .font(.footnote)
            .accessibility(identifier: "toggleEditing")
        }
    }
    
    func toggleEditing() {
        withAnimation {
            viewState.settings.isEditing.toggle()
        }
    }
}


struct ToggleEditingButton_Previews: PreviewProvider {
    static var previews: some View {
        let context = PreviewContext()
        return context.inject(into:
            VStack {
                Text(context.state.settings.isEditing ? "Editing Enabled" : "Editing Disabled")
                ToggleEditingButton()
            }
        )
    }
}

