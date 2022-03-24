// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import AppKit
import Foundation

enum ImageMode: CaseIterable {
    case foreground
    case background
}

extension ItemStatus: CaseIterable {
    public static var allCases: [ItemStatus] {
        return [.unknown, .succeeded, .failed, .queued, .running]
    }

    var asString: String {
        switch self {
            case .unknown: return "StatusUnknown"
            case .succeeded: return "StatusPassing"
            case .failed: return "StatusFailing"
            case .running: return "StatusRunning"
            case .queued: return "StatusQueued"
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

@objc class AppKitBridgeSingleton: NSResponder {
    static let imageWidth = 18.0
    static let imageSize = NSSize(width: imageWidth, height: imageWidth)
    
    typealias StatusImages = [ItemStatus:NSImage]
    typealias ImageTable = [ImageMode:StatusImages]
    
    let images = setupImages()
    let appName = Bundle.main.infoDictionary?["CFBundleName"] as! String
    
    var delegate: AppKitBridgeDelegate?
    var windowInterceptor: InterceptingDelegate?
    var mainWindow: NSWindow?
    var statusItem: NSStatusItem?
    var toolbar: NSToolbar?
    var editingItem: NSToolbarItem?
    lazy var unlockedImage = systemImage("lock.open.fill", label: "Done Editing")
    lazy var lockedImage = systemImage("lock.fill", label: "Edit Repos")
    lazy var addImage = systemImage("plus", label: "Add Repo")
    
    private var _status: ItemStatus = .unknown
    
    func systemImage(_ name: String, label: String) -> NSImage {
        let image = NSImage(systemSymbolName: name, accessibilityDescription: label)!
        return image
    }
    
    var status: ItemStatus {
        get {
            _status
        }
        set {
            _status = newValue
            updateImage()
            updateWindow()
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
            button.setAccessibilityIdentifier("ActionStatusStatusMenu")
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


extension AppKitBridgeSingleton: AppKitBridge {
    func reveal(inFinder url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    func setup(with delegate: AppKitBridgeDelegate) {
        self.delegate = delegate
        self.nextResponder = NSApp.nextResponder
        NSApp.nextResponder = self

        NotificationCenter.default.addObserver(forName: NSApplication.didBecomeActiveNotification, object: nil, queue: nil) { notification in
            self.updateImage()
        }

        NotificationCenter.default.addObserver(forName: NSApplication.didResignActiveNotification, object: nil, queue: nil) { notification in
            self.updateImage()
        }

    }
        
    func updateWindow() {
        if mainWindow == nil, let window = NSApp.mainWindow {
            windowInterceptor = InterceptingDelegate(window: window, interceptor: self)
            mainWindow = window
            
            // if UI testing, force the window to a known position
            let environment = ProcessInfo.processInfo.environment
            let screens = NSScreen.screens
            if let screen = environment["UITestScreen"], let index = Int(screen), index < screens.count {
                let frame = screens[index].frame
                window.setFrameTopLeftPoint(CGPoint(x: frame.minX + 64.0, y: frame.maxY - 64.0))
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
    
    var showAddButton: Bool {
        get { return addButtonVisible }
        set {
            if newValue && !addButtonVisible, let index = index(ofToolbarItemIdentifier: .editButton) {
                toolbar?.insertItem(withItemIdentifier: .addButton, at: index)
            } else if !newValue, let index = index(ofToolbarItemIdentifier: .addButton) {
                toolbar?.removeItem(at: index)
            }
        }
    }
    
    var showWindowSelector: Selector {
        return #selector(handleShow(_:))
    }

}

extension AppKitBridgeSingleton: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        if menu == statusItem?.menu {
            menu.removeAllItems()
            if let menuSource = delegate {
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
            menu.addItem(withTitle: "Show \(appName)", action: #selector(handleShow(_:)), keyEquivalent: "")
            menu.addItem(withTitle: "Preferences…", action: #selector(handlePreferences(_:)), keyEquivalent: "")
            menu.addItem(withTitle: "Quit \(appName)", action: #selector(handleQuit(_:)), keyEquivalent: "")
        }
    }

    @IBAction func handleItem(_ sender: Any) {
        if let item = sender as? NSMenuItem {
            delegate?.selectItem(item.tag)
        }
    }

    @IBAction func handleAbout(_ sender: Any) {
        NSApp.orderFrontStandardAboutPanel(self)
    }

    @IBAction func handlePreferences(_ sender: Any) {
        handleShow(sender)
        delegate?.showPreferences()
    }
    
    @IBAction func handleShow(_ sender: Any) {
        mainWindow?.setIsVisible(true)
        mainWindow?.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
    }

    @IBAction func handleQuit(_ sender: Any) {
        // if we've been given a screenshot folder, reveal it in the finder
        if let string = ProcessInfo.processInfo.environment["Screenshots"], let url = URL(string: string) {
            NSWorkspace.shared.open(url)
        }
        
        NSApp.terminate(self)
    }

    @IBAction func handleHelp(_ sender: Any) {
        print("help")
    }
}

extension AppKitBridgeSingleton: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.setIsVisible(false)
        return false;
    }
}


extension NSToolbarItem.Identifier {
    static var titleLabel = Self.init("title")
    static var addButton = Self.init("add")
    static var editButton = Self.init("edit")
    static var padding = Self.init("padding")
}

extension AppKitBridgeSingleton: NSToolbarDelegate {
    var addButtonVisible: Bool {
        return index(ofToolbarItemIdentifier: .addButton) != nil
    }
    
    func index(ofToolbarItemIdentifier itemIdentifier: NSToolbarItem.Identifier) -> Int? {
        return toolbar?.items.firstIndex(where: { $0.itemIdentifier == itemIdentifier })
    }
    
    func makeToolbar() -> Any {
        let toolbar = NSToolbar(identifier: "test")
        toolbar.delegate = self
        toolbar.displayMode = .iconAndLabel
        toolbar.sizeMode = .small
        toolbar.centeredItemIdentifier = .titleLabel
        self.toolbar = toolbar
        
        return toolbar
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        switch itemIdentifier {
            case .titleLabel:
                guard let title = mainWindow?.title else { return nil }
                item.view = NSTextField(labelWithString: title)

            case .addButton:
                let button = NSButton(image: addImage, target: self, action: #selector(handleAdd(_:)))
                button.isBordered = false
                item.view = button

            case .editButton:
                let button = NSButton(image: lockedImage, target: self, action: #selector(handleEdit(_:)))
                button.isBordered = false
                item.view = button
                editingItem = item
            
            case .padding:
                let view = NSView(frame: .zero)
                item.view = view

            default:
                return nil
        }

        return item
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.flexibleSpace,.titleLabel,.flexibleSpace,.editButton, .padding]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.titleLabel, .editButton]
    }
    
    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return []
    }
    
    @IBAction func handleEdit(_ sender: Any) {
        if let isEditing = delegate?.toggleEditing(), let item = editingItem, let button = item.view as? NSButton {
            button.image = isEditing ? unlockedImage : lockedImage
            button.isHighlighted = isEditing
        }
    }
    
    @IBAction func handleAdd(_ sender: Any) {
        delegate?.addItem()
    }
}
