// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


import UIKit
import SwiftUI

@UIApplicationMain
class AppDelegate: AppCommon {
    var appKitBridge: AppKitBridge? = nil
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    override func oneTimeSetup() {
        loadBridge()
        repos.block = { self.refreshBridge() }

        super.oneTimeSetup()
    }
    
    fileprivate func refreshBridge() {
        appKitBridge?.passing = repos.failingCount == 0
    }
    
    fileprivate func loadBridge() {
        if let bridgeURL = Bundle.main.url(forResource: "AppKitBridge", withExtension: "bundle"), let bundle = Bundle(url: bridgeURL) {
            if let cls = bundle.principalClass as? NSObject.Type {
                if let instance = cls.init() as? AppKitBridge {
                    appKitBridge = instance
                    instance.setup()
                    instance.setDataSource(self)
                }
            }
        }
    }
}

extension AppDelegate: MenuDataSource {
    func itemCount() -> Int {
        return repos.items.count
    }
    
    func name(forItem item: Int) -> String {
        return repos.items[item].name
    }
    
    func status(forItem item: Int) -> ItemStatus {
        switch repos.items[item].state {
            case .unknown: return .unknown
            case .failing: return .failed
            case .passing: return .succeeded
        }
    }
    
    func selectItem(_ item: Int) {
        print("selected item \(item)")
    }
    
    func handleShow() {
    }
    
    func handlePreferences() {
        
    }
    
//    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        if let item = sender as? NSObject {
//            print(item.value(forKey: "selector"))
//            print(item.value(forKey: "target"))
//        }
//        return super.canPerformAction(action, withSender: sender)
//    }
}
