// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct OtherPrefsView: View {
  @Binding var owner: String
  @Binding var oldestNewest: Bool

  var body: some View {
    Form {
      TextField("Default Owner", text: $owner)
      Toggle("Test lowest & highest Swift", isOn: $oldestNewest)
    }
  }
}
