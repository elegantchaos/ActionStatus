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
        Button(action: { self.viewState.isEditing.toggle() }) {
            SystemImage(viewState.isEditing ? "ellipsis.circle.fill" : "ellipsis.circle")
        }
    }
}
#endif
