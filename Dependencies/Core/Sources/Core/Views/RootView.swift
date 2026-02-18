// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/05/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import Combine

public enum Focus: Hashable, Equatable {
    case repo(UUID)
    case prefs
}

struct RootView: View {
    @Namespace() var defaultNamespace
    @EnvironmentObject var context: ViewContext
    @EnvironmentObject var model: Model
    @State var focusState = FadingFocusState()
    
    #if os(tvOS)
    @FocusState var focus: Focus?
    #endif
    
    var body: some View {
        VStack(alignment: .center) {
            if model.count == 0 {
                NoReposView()
            } else if context.settings.isEditing {
                #if os(tvOS)
                    RepoListView(namespace: defaultNamespace, focus: $focus)
                #else
                RepoListView(namespace: defaultNamespace)
                #endif
            } else {
#if os(tvOS)
                RepoGridView(namespace: defaultNamespace, focus: $focus)
#else
                RepoGridView(namespace: defaultNamespace)
#endif
            }
            
            Spacer()
            #if os(tvOS)
            FooterView(namespace: defaultNamespace, focus: $focus)
            #else
            FooterView(namespace: defaultNamespace)
            #endif
        }
        .onAppear(perform: handleAppear)
        #if os(tvOS)
        .focusScope(defaultNamespace)
        .environmentObject(focusState)
        .onChange(of: focus) { value in
            focusState.handleFocusChanged()
        }
        #endif
    }
    
    func handleAppear() {
        #if os(tvOS)
        focusState.handleFocusChanged()
        #endif
    }

}
