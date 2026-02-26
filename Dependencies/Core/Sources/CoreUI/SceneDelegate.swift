// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(UIKit)
  import SwiftUI
  import UIKit

  open class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    public var window: UIWindow?

    open func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
      makeScene(scene, willConnectTo: session, options: connectionOptions)
    }

    open func makeScene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
      let app = Engine.shared
      let content = app.applyEnvironment(to: ContentView())

      if let windowScene = scene as? UIWindowScene {
        setup(windowScene)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: content)
        self.window = window
        app.rootController = window.rootViewController
        window.makeKeyAndVisible()
      }
    }

    open func setup(_ windowScene: UIWindowScene) {

    }
  }
#endif
