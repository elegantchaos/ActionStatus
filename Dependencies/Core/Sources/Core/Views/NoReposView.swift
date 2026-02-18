// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

public struct NoReposView: View {
  @EnvironmentObject var model: Model
  @EnvironmentObject var context: ViewContext

  public init() {
  }

  public var body: some View {
    VStack(alignment: .center) {
      Spacer()
      Text("No Repos Configured").font(.largeTitle)
      Spacer()

      #if os(tvOS)
        Text(
          """
          The repo list is stored in iCloud and shared
          between all of your devices.

          To monitor repos here, you need to first add them
          on another device, using either the
          iOS or macOS version of Action Status.
          """
        )
        .font(.headline)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        Spacer()
      #else
        Button(action: makeInitialView) {
          Text("Configure a repo to begin monitoring it.")
        }
      #endif
    }
  }

  func makeInitialView() {
    context.addRepo(to: model)
  }

}
