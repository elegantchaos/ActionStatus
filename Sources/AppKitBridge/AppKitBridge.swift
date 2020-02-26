// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 14/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import AppKit
import Sparkle
import SparkleBridge

@objc class AppKitBridgeImp: NSResponder {
    static let imageSize = NSSize(width: 16.0, height: 16.0)
    let passingImage = setupImage("StatusPassing")
    let failingImage = setupImage("StatusFailing")
    let unknownImage = setupImage("StatusUnknown")
    let appName = Bundle.main.infoDictionary?["CFBundleName"] as! String
    
    var updateDriver: WrappedUserDriver!
    var updater: SPUUpdater!
    
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
    
    func setupSparkle(driver: SparkleDriver) {
        let hostBundle = Bundle.main
        updateDriver = WrappedUserDriver(wrapping: driver)
        updater = SPUUpdater(hostBundle: hostBundle, applicationBundle: hostBundle, userDriver: updateDriver, delegate: self)
        do {
            try updater.start()
        } catch {
            // Delay the alert four seconds so it doesn't show RIGHT as the app launches, but also doesn't interrupt the user once they really get to work.
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .seconds(4))) {
                let alert = NSAlert()
                alert.messageText = "Unable to Check For Updates"
                alert.informativeText = "The update checker failed to start correctly. You should contact the app developer to report this issue and verify that you have the latest version."
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
        }
    }
}


extension AppKitBridgeImp: AppKitBridge {
    func setup(withSparkleDriver sparkleDriver: Any) {
        print(sparkleDriver)
        if let driver = sparkleDriver as? SparkleDriver {
            setupSparkle(driver: driver)
        }

        self.nextResponder = NSApp.nextResponder
        NSApp.nextResponder = self
    }
    
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
        updater.checkForUpdates()
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
}

class CustomAlert: NSWindowController, SPUStandardUpdateAlert {
    @objc var allowsAutomaticUpdates: Bool = false
    @objc var descriptionText: String = "blah"
    
//    @IBOutlet var releaseNotesView: WKWebView!
    @IBOutlet var releaseNotesContainerView: NSView!
    @IBOutlet var descriptionField: NSTextField!
    @IBOutlet var automaticallyInstallUpdatesButton: NSButton!
    @IBOutlet var installButton: NSButton!
    @IBOutlet var skipButton: NSButton!
    @IBOutlet var laterButton: NSButton!

    override func windowDidLoad() {
        
    }
    func showUpdateReleaseNotes(with downloadData: SPUDownloadData) {
        
    }
    
    func showReleaseNotesFailedToDownload() {
        
    }
    
    
}

extension AppKitBridgeImp: SPUStandardUserDriverDelegate {
    func standardUserDriverMakeAlert(with item: SUAppcastItem, alreadyDownloaded: Bool, host aHost: SUHost, versionDisplayer aVersionDisplayer: SUVersionDisplay, completionBlock block: @escaping (SPUUpdateAlertChoice) -> Void) -> NSWindowController & SPUStandardUpdateAlert {
        return CustomAlert(windowNibName: "AlternateAlert")
    }
    
    func standardUserDriverMakeAlert(with item: SUAppcastItem, host aHost: SUHost, versionDisplayer aVersionDisplayer: SUVersionDisplay, resumableCompletionBlock block: @escaping (SPUInstallUpdateStatus) -> Void) -> NSWindowController & SPUStandardUpdateAlert {
        return CustomAlert(windowNibName: "AlternateAlert")
    }
    
    func standardUserDriverMakeAlert(with item: SUAppcastItem, host aHost: SUHost, versionDisplayer aVersionDisplayer: SUVersionDisplay, informationalCompletionBlock block: @escaping (SPUInformationalUpdateAlertChoice) -> Void) -> NSWindowController & SPUStandardUpdateAlert {
        return CustomAlert(windowNibName: "AlternateAlert")
    }
}
