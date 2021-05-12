// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/05/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct RootView: View {
    @Namespace() var defaultNamespace
    @EnvironmentObject var context: ViewContext
    @EnvironmentObject var model: Model

    var body: some View {
        VStack(alignment: .center) {
            if model.count == 0 {
                NoReposView()
            } else if context.settings.isEditing {
                RepoListView(namespace: defaultNamespace)
            } else {
                RepoGridView(namespace: defaultNamespace)
            }
            
            Spacer()
            FooterView()
        }
    }
}
