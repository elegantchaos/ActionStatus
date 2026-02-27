// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

public struct AddButton: View {
  @Environment(ViewContext.self) var context

  public init() {
  }

  public var body: some View {
    Button(action: addRepo) {
      Text("Add")
    }
    .accessibility(identifier: "addButton")
    .foregroundColor(.black)
    .animation(.easeInOut)
  }

  func addRepo() {
    context.presentedSheet = .editRepo(nil)
  }
}

struct AddButton_Previews: PreviewProvider {
  static var previews: some View {
    PreviewContext().inject(into: AddButton())
  }
}
