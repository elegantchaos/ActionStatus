// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/05/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import Combine

class FocusThingy: ObservableObject {
    @Published var alpha: Double = 1.0
    @Published var focussedRepo: UUID?
    
#if os(tvOS)
    var listeners: [AnyCancellable] = []

//    @available(tvOS 15.0, *) var focusBinding: Binding<Focus?> {
//        Binding<Focus?>(
//            get: { self.prefsFocussed },
//            set: { value in self.prefsFocussed = value }
//        )
//    }
//
    init() {
//        if #available(tvOS 15.0, *) {
//            let listener = prefsFocussed.publisher.sink { newValue in
//                withAnimation {
//                    self.alpha = 1.0
//                }
//            }
//            listeners.append(listener)
//        }
    }
    
    func handleFocusChanged() {
        alpha = 1.0
        withAnimation(.easeIn(duration: 2.0)) {
            alpha = 0.1
        }
    }

#endif
    
}

#if os(tvOS)
extension FocusThingy: Equatable {
    static func == (lhs: FocusThingy, rhs: FocusThingy) -> Bool {
        lhs.focussedRepo == rhs.focussedRepo
    }
}
#endif

public enum Focus: Hashable, Equatable {
    case repo(UUID)
    case prefs
}

struct RootView: View {
    @Namespace() var defaultNamespace
    @EnvironmentObject var context: ViewContext
    @EnvironmentObject var model: Model
    @State var focusState = FocusThingy()
    
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
            FooterView(namespace: defaultNamespace, focus: $focus)
        }
        .focusScope(defaultNamespace)
        .environmentObject(focusState)
        .onAppear(perform: handleAppear)
        .onChange(of: focus) { value in
            focusState.handleFocusChanged()
        }
    }
    
    func handleAppear() {
        #if os(tvOS)
        focusState.handleFocusChanged()
        #endif
    }

}
