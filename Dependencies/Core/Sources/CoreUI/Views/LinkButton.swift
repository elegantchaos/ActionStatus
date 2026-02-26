// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct LinkButton: View {
  @Environment(ViewContext.self) var context

  let url: URL

  var body: some View {
    Button(action: handleLink) {
      Image(systemName: context.linkIcon)
        .foregroundColor(.gray)
    }
  }

  func handleLink() {
    context.host.open(url: url)
  }
}
