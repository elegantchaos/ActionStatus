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
    
    func rowPadding() -> some View {
        return self.padding(.horizontal, 80.0) // TODO: remove this special case
    }
    
    #elseif canImport(UIKit)
    
    // MARK: iOS/tvOS
    
    func rowPadding() -> some View {
//        return self.padding(.horizontal)
        return self
    }

    #endif
}
