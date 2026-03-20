// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct EditSectionView<Content: View>: View {
  @ViewBuilder var content: () -> Content
  let header: LocalizedStringResource
  let footer: LocalizedStringResource

  init(_ header: LocalizedStringResource, footer: LocalizedStringResource, @ViewBuilder content: @escaping () -> Content) {
    self.content = content
    self.header = header
    self.footer = footer
  }

  var body: some View {
    Section {
      content()
    } header: {
      Text(header)
    } footer: {
      Text(footer)
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
  }
}

#if !VALIDATING
  #Preview("Section") {
    Form {
      EditSectionView("Header", footer: "Footer") {
        Text("Some Content Here")
      }
    }
    .formStyle(.grouped)
  }
#endif
