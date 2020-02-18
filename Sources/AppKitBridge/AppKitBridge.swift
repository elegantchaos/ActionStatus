// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 14/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import AppKit

@objc class AppKitBridgeImp: NSResponder, AppKitBridge {
    
    static let imageSize = NSSize(width: 16.0, height: 16.0)
    let passingImage = setupPassingImage()
    let failingImage = setupFailingImage()
    let appName = Bundle.main.infoDictionary?["CFBundleName"] as! String
    var menuSource: MenuDataSource?
    var windowInterceptor: InterceptingDelegate?
    var mainWindow: NSWindow?
    var item: NSStatusItem!
    var passing: Bool {
        get { return item.button?.image == passingImage }
        set { item.button?.image = newValue ? passingImage : failingImage }
    }

    @objc func setup() {
        let status = NSStatusBar.system
        item = status.statusItem(withLength: 22)
        if let button = item.button {
            button.title = "ActionStatus"
            button.image = passingImage
        }
        
        let menu = NSMenu(title: "Repos")
        menu.delegate = self
        item.menu = menu
        
        self.nextResponder = NSApp.nextResponder
        NSApp.nextResponder = self
    }
    
    @objc func didSetup(_ uiWindow: Any) {
        for window in NSApp.windows {
            if window.title == appName {
                windowInterceptor = InterceptingDelegate(window: window, interceptor: self)
                mainWindow = window
            }
        }
    }
    
    @objc func setDataSource(_ source: MenuDataSource) {
        menuSource = source
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

extension AppKitBridgeImp: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        if menu == item.menu {
            menu.removeAllItems()
            if let menuSource = menuSource {
                for n in 0 ..< menuSource.itemCount() {
                    let name = menuSource.name(forItem: n)
                    let item = menu.addItem(withTitle: name, action: #selector(handleItem(_:)), keyEquivalent: "")
                    switch menuSource.status(forItem: n) {
                        case .succeeded: item.image = passingImage
                        case .failed: item.image = failingImage
                        default: item.image = nil
                    }
                    
                    item.tag = n
                }
            }
            
            menu.addItem(NSMenuItem.separator())
            menu.addItem(withTitle: "About \(appName)", action: #selector(handleAbout(_:)), keyEquivalent: "")
            menu.addItem(withTitle: "Show Repo List", action: #selector(handleShow(_:)), keyEquivalent: "")
            menu.addItem(withTitle: "Preferences…", action: #selector(handlePreferences(_:)), keyEquivalent: "")
            menu.addItem(withTitle: "Quit \(appName)", action: #selector(handleQuit(_:)), keyEquivalent: "")
        }
    }

    @IBAction func handleItem(_ sender: Any) {
        if let item = sender as? NSMenuItem {
            menuSource?.selectItem(item.tag)
        }
    }

    @IBAction func handleAbout(_ sender: Any) {
        NSApp.orderFrontStandardAboutPanel(self)
    }

    @IBAction func handlePreferences(_ sender: Any) {
        menuSource?.handlePreferences()
    }

    @IBAction func handleShow(_ sender: Any) {
        mainWindow?.setIsVisible(true)
        mainWindow?.makeKeyAndOrderFront(self)
    }

    @IBAction func handleQuit(_ sender: Any) {
        NSApp.terminate(self)
    }

}

extension AppKitBridgeImp: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.setIsVisible(false)
        return false;
    }
}
