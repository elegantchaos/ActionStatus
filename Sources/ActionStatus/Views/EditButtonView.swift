// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import SwiftUIExtensions

#if canImport(UIKit)
struct EditButton: View {
    @EnvironmentObject var viewState: ViewState

    var body: some View {
        Button(action: toggleEditing) {
            SystemImage(viewState.isEditing ? "lock.open.fill" : "lock.fill")
        }
    }
    
    func toggleEditing() {
        viewState.isEditing.toggle()
    }
}
#endif
