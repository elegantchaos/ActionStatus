// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/02/26.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(tvOS)
  import Application
  import CoreUI
  import SwiftUI

  @main
  struct TVApp: App {
    let engine: Engine

    init() {
      engine = Engine()
      engine.standardLoop()
    }

    var body: some Scene {
      WindowGroup {
        engine.rootView {
          ContentView()
        }
      }
    }
  }
#endif
