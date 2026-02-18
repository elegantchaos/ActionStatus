// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/02/26.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(tvOS)
  import Core
  import SwiftUI

  @main
  struct TVApp: App {
    @UIApplicationDelegateAdaptor(TVApplication.self) private var application

    var body: some Scene {
      WindowGroup {
        Engine.shared.applyEnvironment(to: ContentView())
      }
    }
  }
#endif
