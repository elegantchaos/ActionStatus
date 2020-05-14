// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import ActionStatusCore

struct PreviewContext {

    var repos: [Repo]
    @State var model: Model
    @State var state = ViewState()
    
    init(isEditing: Bool = true) {
        let repos = [
            Repo("ApplicationExtensions", owner: "elegantchaos", workflow: "Tests", state: .failing),
            Repo("Datastore", owner: "elegantchaos", workflow: "Swift", state: .passing),
            Repo("DatastoreViewer", owner: "elegantchaos", workflow: "Build", state: .failing),
            Repo("Logger", owner: "elegantchaos", workflow: "tests", state: .unknown),
            Repo("ViewExtensions", owner: "elegantchaos", workflow: "Tests", state: .passing),
        ]
        
        self.repos = repos
        _model = State(initialValue: Model(repos))

        state.isEditing = isEditing
    }
    
    func inject<Content>(into view: Content) -> some View where Content: View {
        return view
        .environmentObject(model)
        .environmentObject(state)
    }
}
