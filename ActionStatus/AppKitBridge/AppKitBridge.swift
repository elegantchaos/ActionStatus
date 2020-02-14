// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 14/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import AppKit

@objc class AppKitBridgeImp: NSObject, AppKitBridge {
    var item: NSStatusItem!
    
    @objc func setup() {
        let status = NSStatusBar.system
        item = status.statusItem(withLength: 40)
        item.button?.title = "Test"
    }
}
