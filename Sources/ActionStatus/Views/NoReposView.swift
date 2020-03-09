// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import ActionStatusCore

struct NoReposView: View {
    @EnvironmentObject var model: Model
    @EnvironmentObject var viewState: ViewState
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("No Repos Configured").font(.title)
            Spacer()
            Button(action: makeInitialView) {
                Text("Configure a repo to begin monitoring it.")
            }
        }
    }
    
    func makeInitialView() {
        viewState.addRepo(to: model)
    }

}
