// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Modifier that shows a trailing clear button for non-empty text input.
struct ClearButton: ViewModifier {
  /// The text binding cleared when the button is tapped.
  @Binding var text: String

  public func body(content: Content) -> some View {
    content
      .overlay(alignment: .trailing) {
        Button(action: { text = "" }) {
          Image(systemName: "multiply.circle.fill")
            .foregroundColor(.secondary)
        }
        .padding(.trailing, 8)
        .buttonStyle(.borderless)
      }
  }
}
