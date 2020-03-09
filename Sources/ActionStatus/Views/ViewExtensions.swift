// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import SwiftUIExtensions

internal extension View {
    func statusStyle() -> some View {
        return font(.footnote)
    }
    
    #if os(tvOS)
    
    // MARK: tvOS Overrides
    
    func setupNavigation(editAction: @escaping () -> (Void), addAction: @escaping () -> (Void)) -> some View {
        return navigationBarHidden(false)
    }
    func setupNavigationStyle() -> some View {
        return navigationViewStyle(StackNavigationViewStyle())
    }
    func bindEditing(to binding: Binding<Bool>) -> some View {
        return self
    }
    
    func rowPadding() -> some View {
        return self.padding(.horizontal, 80.0) // TODO: remove this special case
    }
    
    #elseif canImport(UIKit)
    
    // MARK: iOS/tvOS
    
    func setupNavigation(addAction: @escaping () -> (Void)) -> some View {
        return navigationBarHidden(false)
        .navigationBarTitle("Action Status", displayMode: .inline)
        .navigationBarItems(
            leading: AddButton(action: addAction),
            trailing: EditButton())
    }
    func setupNavigationStyle() -> some View {
        return navigationViewStyle(StackNavigationViewStyle())
    }
    func bindEditing(to binding: Binding<Bool>) -> some View {
        environment(\.editMode, .constant(binding.wrappedValue ? .active : .inactive))
    }

    func rowPadding() -> some View {
//        return self.padding(.horizontal)
        return self
    }

    #else // MARK: AppKit Overrides
    func setupNavigation(editAction: @escaping () -> (Void), addAction: @escaping () -> (Void)) -> some View {
        return navigationViewStyle(DefaultNavigationViewStyle())
    }
    func setupNavigationStyle() -> some View {
        return navigationViewStyle(DefaultNavigationViewStyle())
    }
    func bindEditing(to binding: Binding<Bool>) -> some View {
        return self
    }
    #endif
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
