// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import AppKit

enum ImageMode: CaseIterable {
    case foreground
    case background
}

extension ItemStatus: CaseIterable {
    public static var allCases: [ItemStatus] {
        return [.failed, .succeeded, .unknown]
    }

    var asString: String {
        switch self {
            case .unknown: return "StatusUnknown"
            case .succeeded: return "StatusPassing"
            case .failed: return "StatusFailing"
        }
    }
    
    func imageName(mode: ImageMode) -> String {
        switch mode {
            case .foreground: return "\(asString)Solid"
            case .background: return asString
        }
    }

    public typealias AllCases = [ItemStatus]
}

@objc class AppKitBridgeImp: NSResponder {
    static let imageSize = NSSize(width: 16.0, height: 16.0)
    
    typealias StatusImages = [ItemStatus:NSImage]
    typealias ImageTable = [ImageMode:StatusImages]
    
    let images = setupImages()
    let appName = Bundle.main.infoDictionary?["CFBundleName"] as! String
    
    var menuSource: MenuDataSource?
    var windowInterceptor: InterceptingDelegate?
    var mainWindow: NSWindow?
    var statusItem: NSStatusItem?
    var editingItem: NSToolbarItem?
    var status: ItemStatus = .unknown
    var showUpdates = false
    
    var passing: Bool {
        get { return status == .succeeded }
        set {
            status = newValue ? .succeeded : .failed
            updateImage()
        }
    }

    class func setupImages() -> ImageTable {
        var images: ImageTable = [:]
        for mode in ImageMode.allCases {
            var modeImages:[ItemStatus:NSImage] = [:]
            for status in ItemStatus.allCases {
                let name = status.imageName(mode: mode)
                let image = NSImage(named: name)!
                image.size = imageSize
                modeImages[status] = image
            }
            images[mode] = modeImages
        }
        return images
    }

    func setupMenu() {
        assert(statusItem == nil)
        let status = NSStatusBar.system
        let newItem = status.statusItem(withLength: 22)
        if let button = newItem.button {
            button.title = "ActionStatus"
        }
        
        let menu = NSMenu(title: "Repos")
        menu.delegate = self
        newItem.menu = menu
        statusItem = newItem
        updateImage()
    }
    
    func tearDownMenu() {
        assert(statusItem != nil)
        NSStatusBar.system.removeStatusItem(statusItem!)
        statusItem = nil
    }
    
    func updateImage() {
        if let button = statusItem?.button {
            let mode: ImageMode = NSApp.isActive ? .foreground : .background
            button.image = (images[mode])?[status]
        }
    }
}


extension AppKitBridgeImp: AppKitBridge {
    func setupCapturingWindowNamed(_ windowName: String, dataSource source: MenuDataSource) {
        menuSource = source

        self.nextResponder = NSApp.nextResponder
        NSApp.nextResponder = self

        NotificationCenter.default.addObserver(forName: NSApplication.didBecomeActiveNotification, object: nil, queue: nil) { notification in
            self.updateImage()
        }

        NotificationCenter.default.addObserver(forName: NSApplication.didResignActiveNotification, object: nil, queue: nil) { notification in
            self.updateImage()
        }

        for window in NSApp.windows {
            if window.title == windowName {
                windowInterceptor = InterceptingDelegate(window: window, interceptor: self)
                mainWindow = window
            }
        }

    }
        
    var showInDock: Bool {
        get { return NSApp.activationPolicy() == .regular }
        set {
            let newPolicy: NSApplication.ActivationPolicy = newValue ? .regular : .accessory
            if newPolicy != NSApp.activationPolicy() {
                let window = NSApp.mainWindow
                NSApp.setActivationPolicy(newPolicy)
                window?.makeKeyAndOrderFront(self)
            }
        }
    }
    
    var showInMenu: Bool {
        get { return statusItem != nil }
        set {
            if newValue && (statusItem == nil) {
                setupMenu()
            } else if !newValue && (statusItem != nil) {
                tearDownMenu()
            }
        }
    }
    
    var showWindowSelector: Selector {
        return #selector(handleShow(_:))
    }

}

extension AppKitBridgeImp: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        if menu == statusItem?.menu {
            menu.removeAllItems()
            if let menuSource = menuSource {
                for n in 0 ..< menuSource.itemCount() {
                    let name = menuSource.name(forItem: n)
                    let item = menu.addItem(withTitle: name, action: #selector(handleItem(_:)), keyEquivalent: "")
                    let status = menuSource.status(forItem: n)
                    item.image = images[.foreground]?[status]
                    item.tag = n
                }
            }
            
            menu.addItem(NSMenuItem.separator())
            menu.addItem(withTitle: "About \(appName)", action: #selector(handleAbout(_:)), keyEquivalent: "")
            menu.addItem(withTitle: "Open \(appName)", action: #selector(handleShow(_:)), keyEquivalent: "")
            menu.addItem(withTitle: "Preferences…", action: #selector(handlePreferences(_:)), keyEquivalent: "")
            if showUpdates {
                menu.addItem(withTitle: "Check For Updates…", action: #selector(handleCheckForUpdates(_:)), keyEquivalent: "")
            }
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
        menuSource?.checkForUpdates()
    }
    
    @IBAction func handleShow(_ sender: Any) {
        mainWindow?.setIsVisible(true)
        mainWindow?.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
    }

    @IBAction func handleQuit(_ sender: Any) {
        NSApp.terminate(self)
    }

    @IBAction func handleHelp(_ sender: Any) {
        print("help")
    }
}

extension AppKitBridgeImp: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.setIsVisible(false)
        return false;
    }
}


extension NSToolbarItem.Identifier {
    static var titleLabel = Self.init("title")
    static var editButton = Self.init("edit")
}

extension AppKitBridgeImp: NSToolbarDelegate {
    func makeToolbar() -> Any {
        let toolbar = NSToolbar(identifier: "test")
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        toolbar.sizeMode = .small
        toolbar.centeredItemIdentifier = .titleLabel
        
        return toolbar
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
            case .titleLabel:
                let item = NSToolbarItem(itemIdentifier: .titleLabel)
                item.view = NSTextField(labelWithString: mainWindow?.title ?? "Action Status")
                return item

            case .editButton:
                let image = NSImage(named: "NSLockLockedTemplate")
                let button = NSButton(image: image!, target: self, action: #selector(handleEdit(_:)))
                button.isBordered = false
                let item = NSToolbarItem(itemIdentifier: .editButton)
                item.view = button
//                item.action = #selector(handleEdit(_:))
//                item.target = self
//                item.isBordered = false
                editingItem = item
                return item
            
            default:
                return nil
        }
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.flexibleSpace,.titleLabel,.flexibleSpace,.editButton]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.titleLabel, .editButton]
    }
    
    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return []
    }
    
    @IBAction func handleEdit(_ sender: Any) {
        if let isEditing = menuSource?.toggleEditing(), let item = editingItem, let button = item.view as? NSButton {
            button.image = NSImage(named: isEditing ? "NSLockUnlockedTemplate" : "NSLockLockedTemplate")
//            button.isBordered = isEditing
            button.isHighlighted = isEditing
//            item.isBordered = isEditing
        }
    }
}
