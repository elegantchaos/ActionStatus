// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/02/26.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(iOS)
  import Core
  import SwiftUI

  @main
  struct MobileApp: App {
    @UIApplicationDelegateAdaptor(MobileApplication.self) private var application

    var body: some Scene {
      WindowGroup {
        Engine.shared.applyEnvironment(to: ContentView())
      }
    }
  }
#endif
