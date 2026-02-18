// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct StatusIcon: View {
  let name: String

  init(_ name: String) {
    self.name = name
  }

  var body: some View {
    Image("\(name)Small")
  }
}

struct StatusIcon_Previews: PreviewProvider {
  static var previews: some View {
    StatusIcon("StatusFailing")
  }
}
