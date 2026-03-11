// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Modifier that shows a trailing clear button for non-empty text input.
struct ClearButton: ViewModifier {
  @Binding var text: String

  public func body(content: Content) -> some View {
    ZStack(alignment: .trailing) {
      content

      if !text.isEmpty {
        Button(action: {
          text = ""
        }) {
          Image(systemName: "multiply.circle.fill")
            .foregroundColor(.secondary)
        }
        .padding(.trailing, 8)
      }
    }
  }
}
