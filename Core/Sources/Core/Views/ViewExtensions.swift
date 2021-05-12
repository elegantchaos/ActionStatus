// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import SwiftUIExtensions

internal struct StatusStyleModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) var horizontalSize
    
    func body(content: Content) -> some View {
        content
            .font(horizontalSize == .compact ? .footnote : .title2)
    }
}

internal extension View {
    func statusStyle() -> some View {
        self
            .modifier(StatusStyleModifier())
    }
}
