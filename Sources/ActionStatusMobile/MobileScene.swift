// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import UIKit

class MobileScene: SceneDelegate {
  override func setup(_ windowScene: UIWindowScene) {
    #if targetEnvironment(macCatalyst)
      if let titlebar = windowScene.titlebar {
        let toolbar = Application.native.appKitBridge?.makeToolbar() as? NSToolbar
        titlebar.titleVisibility = .hidden
        titlebar.toolbar = toolbar
      }
    #endif
  }
}
