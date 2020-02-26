// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 14/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import AppKit
import Sparkle

@objc class AppKitBridgeImp: NSResponder {
    static let imageSize = NSSize(width: 16.0, height: 16.0)
    let passingImage = setupImage("StatusPassing")
    let failingImage = setupImage("StatusFailing")
    let unknownImage = setupImage("StatusUnknown")
    let appName = Bundle.main.infoDictionary?["CFBundleName"] as! String
    var updateController: SPUStandardUpdaterController!
    
    var menuSource: MenuDataSource?
    var windowInterceptor: InterceptingDelegate?
    var mainWindow: NSWindow?
    var item: NSStatusItem?
    
    var passing: Bool {
        get { return item?.button?.image == passingImage }
        set { item?.button?.image = newValue ? passingImage : failingImage }
    }
    
    class func setupImage(_ name: String) -> NSImage {
        let image = NSImage(named: name)!
        image.size = imageSize
        return image
    }

    func setupMenu() {
        assert(item == nil)
        let status = NSStatusBar.system
        let newItem = status.statusItem(withLength: 22)
        if let button = newItem.button {
            button.title = "ActionStatus"
            button.image = unknownImage
        }
        
        let menu = NSMenu(title: "Repos")
        menu.delegate = self
        newItem.menu = menu
        item = newItem
    }
    
    func tearDownMenu() {
        assert(item != nil)
        NSStatusBar.system.removeStatusItem(item!)
        item = nil
    }
}

extension AppKitBridgeImp: AppKitBridge {
    var showInDock: Bool {
        get { return item != nil }
        set { }
    }
    
    var showInMenu: Bool {
        get { return item != nil }
        set {
            if newValue && (item == nil) {
                setupMenu()
            } else if !newValue && (item != nil) {
                tearDownMenu()
            }
        }
    }
    
    @objc func setup() {
        updateController = SPUStandardUpdaterController(updaterDelegate: self, userDriverDelegate: nil)
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
}

extension AppKitBridgeImp: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        if menu == item?.menu {
            menu.removeAllItems()
            if let menuSource = menuSource {
                for n in 0 ..< menuSource.itemCount() {
                    let name = menuSource.name(forItem: n)
                    let item = menu.addItem(withTitle: name, action: #selector(handleItem(_:)), keyEquivalent: "")
                    switch menuSource.status(forItem: n) {
                        case .succeeded: item.image = passingImage
                        case .failed: item.image = failingImage
                        default: item.image = unknownImage
                    }
                    
                    item.tag = n
                }
            }
            
            menu.addItem(NSMenuItem.separator())
            menu.addItem(withTitle: "About \(appName)", action: #selector(handleAbout(_:)), keyEquivalent: "")
            menu.addItem(withTitle: "Open \(appName)", action: #selector(handleShow(_:)), keyEquivalent: "")
            menu.addItem(withTitle: "Preferences…", action: #selector(handlePreferences(_:)), keyEquivalent: "")
            menu.addItem(withTitle: "Check For Updates…", action: #selector(handleCheckForUpdates(_:)), keyEquivalent: "")
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
        let command = NSSelectorFromString("orderFrontPreferencesPanel:")
        NSApp.perform(command)
    }

    @IBAction func handleCheckForUpdates(_ sender: Any) {
        updateController.checkForUpdates(sender)
    }
    
    @IBAction func handleShow(_ sender: Any) {
        mainWindow?.setIsVisible(true)
        mainWindow?.makeKeyAndOrderFront(self)
    }

    @IBAction func handleQuit(_ sender: Any) {
        NSApp.terminate(self)
    }

    func showHandler() -> Selector {
        return #selector(handleShow(_:))
    }
}

extension AppKitBridgeImp: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.setIsVisible(false)
        return false;
    }
}

extension AppKitBridgeImp: SPUUpdaterDelegate {
    func updaterDidNotFindUpdate(_ updater: SPUUpdater) {
        print("arse")
    }
    
    func updater(_ updater: SPUUpdater, didFinishLoading appcast: SUAppcast) {
        print("arse")
    }
    
    func updater(_ updater: SPUUpdater, willScheduleUpdateCheckAfterDelay delay: TimeInterval) {
        print("delay \(delay)")
    }
}
