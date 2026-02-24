// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct EditRepoButton: View {
  @EnvironmentObject var context: ViewContext

  let repo: Repo

  var body: some View {
    Button(action: handleTapped) {
      Image(systemName: context.editButtonIcon)
    }
    .accessibility(identifier: "editButton")
    .foregroundColor(.black)
  }

  func handleTapped() {
    context.presentedSheet = .editRepo(repo)
  }
}

struct EditButton_Previews: PreviewProvider {
  static var previews: some View {
    let context = PreviewContext()
    return context.inject(into: EditRepoButton(repo: context.testRepo))
  }
}
