// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct PreviewContext {

    @State var model = TestModel()
    @State var state = ViewState(host: PreviewHost())
    
    init(isEditing: Bool = true) {
        state.isEditing = isEditing
    }
    
    var testRepo: Repo {
        model.repos.first!
    }
    
    func inject<Content>(into view: Content) -> some View where Content: View {
        return view
        .environmentObject(model)
        .environmentObject(state)
    }
}
