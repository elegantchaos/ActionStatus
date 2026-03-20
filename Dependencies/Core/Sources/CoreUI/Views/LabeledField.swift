// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Icons
import SwiftUI

struct LabeledField: View {
  @Binding var text: String
  let label: LocalizedStringResource
  let prompt: LocalizedStringResource
  let icon: Icon
  let clearable: Bool
  
  init(_ text: Binding<String>, label: LocalizedStringResource, prompt: LocalizedStringResource, icon: Icon, clearable: Bool = true) {
    _text = text
    self.label = label
    self.prompt = prompt
    self.icon = icon
    self.clearable = clearable
  }
  
  var body: some View {
    let field = TextField(label, text: $text, prompt: Text(prompt))
      .labelsHidden()
      .labeledContentStyle(LabeledFieldContentStyle())
      .multilineTextAlignment(.leading)
#if os(macOS)
      .multilineTextAlignment(.leading)
      .textFieldStyle(.roundedBorder)
#else
      .keyboardType(.alphabet)
      .textInputAutocapitalization(.never)
      .autocorrectionDisabled(true)
#if os(tvOS)
      .textFieldStyle(.automatic)
#else
      .textFieldStyle(.roundedBorder)
#endif
#endif
    
#if os(macOS)
    return LabeledContent(label, icon: icon) {
      if clearable {
        field
          .modifier(ClearButton(text: $text))
      } else {
        field
      }
    }
#else
    return VStack(alignment: .leading) {
      HStack {
        Image(icon: icon)
        if clearable {
          field
            .modifier(ClearButton(text: $text))
        } else {
          field
        }
      }
    }
#endif
  }
}

struct LabeledFieldContentStyle: LabeledContentStyle {
  func makeBody(configuration: Configuration) -> some View {
    HStack {
      configuration.label
      configuration.content
    }
  }
}

#Preview("LabelledField") {
  @Previewable @State var name = "name"
  
  Form {
    LabeledField($name, label: "label", prompt: "prompt", icon: .name)
  }
  //  .labelStyle(.iconOnly)
  .formStyle(.grouped)
}
