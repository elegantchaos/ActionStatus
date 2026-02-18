// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import SwiftUIExtensions

internal struct StatusStyleModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.title2)
  }
}

internal extension View {
  func statusStyle() -> some View {
    self
      .modifier(StatusStyleModifier())
  }
}
