// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


import UIKit
import SwiftUI

@UIApplicationMain
class AppDelegate: AppCommon {
    var appKitBridge: AppKitBridge? = nil
     
    override func setup(withOptions options: LaunchOptions) {
        loadBridge()
        repos.block = { self.refreshBridge() }

        super.setup(withOptions: options)
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
    
    override func buildMenu(with builder: UIMenuBuilder) {
        if let bridge = appKitBridge, builder.system == .main {
            let bundleID = Bundle.main.bundleIdentifier!
            let command = UIKeyCommand(title: "Show Status Window", image: nil, action: bridge.showHandler(), input: "0", modifierFlags: .command, propertyList: nil)
            let menu = UIMenu(title: "", image: nil, identifier: UIMenu.Identifier("\(bundleID).show"), options: .displayInline, children: [command])
            builder.insertChild(menu, atEndOfMenu: .window)
        }
        
        next?.buildMenu(with: builder)
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
    
    func handlePreferences() {
        
    }
}


