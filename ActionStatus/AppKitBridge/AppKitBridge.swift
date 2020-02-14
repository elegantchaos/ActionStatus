// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 14/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import AppKit

@objc class AppKitBridgeImp: NSObject, AppKitBridge {
    static let imageSize = NSSize(width: 16.0, height: 16.0)
    let passingImage = setupPassingImage()
    let failingImage = setupFailingImage()
    var item: NSStatusItem!
    var passing: Bool {
        get { return item.button?.image == passingImage }
        set { item.button?.image = newValue ? passingImage : failingImage }
    }

    @objc func setup() {
        let status = NSStatusBar.system
        item = status.statusItem(withLength: 22)
        item.button?.title = "ActionStatus"
        item.button?.image = passingImage
    }

    
    class func setupPassingImage() -> NSImage {
        let image = NSImage(named: "StatusPassing")!
        image.size = imageSize
        return image
    }

    class func setupFailingImage() -> NSImage {
        let image = NSImage(named: "StatusFailing")!
        image.size = imageSize
        return image
    }

}
