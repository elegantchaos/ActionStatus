// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 09/03/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import SwiftUIExtensions

#if canImport(UIKit)
struct EditButton: View {
    @EnvironmentObject var viewState: ViewState

    var body: some View {
        Button(action: { self.viewState.isEditing.toggle() }) {
            SystemImage(viewState.isEditing ? "hammer.fill" : "hammer").font(.title)
        }
    }
}
#endif
