// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


import Core
import Combine
import Logger
import SwiftUI
import UIKit

extension TimeInterval {
    static let statusCycleInterval = 1.5
}

extension Application {
    class var native: MobileApplication {
        UIApplication.shared.delegate as! MobileApplication
    }
}

@UIApplicationMain
class MobileApplication: Application {
    override class var shared: MobileApplication {
        UIApplication.shared.delegate as! MobileApplication
    }

    var appKitBridge: AppKitBridge?
    var editingSubscriber: AnyCancellable?
    var updateTimer: Timer?
    
    override var filePickerClass: FilePicker.Type { return MobileFilePicker.self }

    override func setUp(withOptions options: LaunchOptions, completion: @escaping SetupCompletion) {
        super.setUp(withOptions: options) { [self] options in
            _ = ensureBridgeLoaded()
            
            let timer = Timer(timeInterval: .statusCycleInterval, repeats: true) { _ in
                self.updateBridge()
            }
            
            RunLoop.main.add(timer, forMode: .default)
            updateTimer = timer
            
            completion(options)
        }
        
    }
    
    override func updateRepoState() {
        super.updateRepoState()
        updateBridge()
    }
    
    override func setupDefaultSettings() {
        super.setupDefaultSettings()
        UserDefaults.standard.register(defaults: [
            .showInMenuKey: true,
            .showInDockKey: true
            ]
        )
    }
    
    override func loadSettings() {
        super.loadSettings()
        updateBridge()
        
        if let bridge = appKitBridge {
            settingsChannel.log("\(String.showInMenuKey) is \(bridge.showInMenu)")
            settingsChannel.log("\(String.showInDockKey) is \(bridge.showInDock)")
        }
    }

    override func reveal(url: URL) {
        if let bridge = ensureBridgeLoaded() {
            bridge.reveal(inFinder: url)
        } else {
            super.reveal(url: url)
        }
    }
    
    fileprivate func status(for state: Repo.State) -> ItemStatus {
        return ItemStatus(rawValue: state.rawValue) ?? .unknown
    }

    fileprivate func updateBridge() {
        guard let bridge = ensureBridgeLoaded() else { return }
        bridge.showInMenu = UserDefaults.standard.bool(forKey: .showInMenuKey)
        bridge.showInDock = UserDefaults.standard.bool(forKey: .showInDockKey)
        bridge.showAddButton = context.settings.isEditing
        
        let combined = status.combinedState
        let index = Int(Date.timeIntervalSinceReferenceDate / .statusCycleInterval) % combined.count
        let status = self.status(for: self.status.combinedState[index])
        bridge.status = status
    }

    @discardableResult
    fileprivate func ensureBridgeLoaded() -> AppKitBridge? {
        if appKitBridge == nil {
            appKitBridge = loadBridge()
        }
        return appKitBridge
    }
    
    fileprivate func loadBridge() -> AppKitBridge? {
        #if targetEnvironment(macCatalyst)
        let principalClassName = "AppKitBridge.AppKitBridgeSingleton"
        if let cls = NSClassFromString(principalClassName) as? NSObject.Type,
           let instance = cls.init() as? AppKitBridge {
            settingsChannel.log("Loaded bridge class directly: \(principalClassName)")
            instance.setup(with: self)
            return instance
        }

        let candidateURLs: [URL?] = [
            Bundle.main.url(forResource: "AppKitBridge", withExtension: "bundle"),
            Bundle.main.builtInPlugInsURL?.appendingPathComponent("AppKitBridge.bundle"),
            Bundle.main.privateFrameworksURL?.appendingPathComponent("AppKitBridge.bundle"),
            Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/AppKitBridge.bundle"),
        ]

        for bridgeURL in candidateURLs.compactMap({ $0 }) {
            guard let bundle = Bundle(url: bridgeURL) else {
                settingsChannel.log("Found bridge URL but couldn't create Bundle: \(bridgeURL.path)")
                continue
            }

            if !bundle.isLoaded, !bundle.load() {
                settingsChannel.log("Failed to load AppKitBridge bundle at \(bridgeURL.path)")
                continue
            }

            if let cls = (bundle.principalClass ?? NSClassFromString(principalClassName)) as? NSObject.Type,
               let instance = cls.init() as? AppKitBridge {
                settingsChannel.log("Loaded bridge from bundle: \(bridgeURL.path)")
                instance.setup(with: self)
                return instance
            } else {
                settingsChannel.log("Bridge principal class missing or wrong type in bundle: \(bridgeURL.path)")
            }
        }

        settingsChannel.log("Failed to load AppKitBridge; menu extra and dock control are unavailable.")
        #endif
        return nil
    }
    
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        
        if builder.system == .main {
            builder.remove(menu: .services)
            builder.remove(menu: .format)
            builder.remove(menu: .toolbar)

            replacePreferences(with: builder)
            replaceQuit(with: builder)
            buildShowStatus(with: builder)
            buildAddLocal(with: builder)
        }

        next?.buildMenu(with: builder)
    }
    
    @objc func showHelp(_ sender: Any) {
        if let url = URL(string: "https://actionstatus.elegantchaos.com/help") {
            UIApplication.shared.open(url)
        }
    }

    func buildShowStatus(with builder: UIMenuBuilder) {
        if let bridge = ensureBridgeLoaded() {
            let command = UIKeyCommand(title: "Show Status Window", image: nil, action: bridge.showWindowSelector, input: "0", modifierFlags: .command, propertyList: nil)
            let menu = UIMenu(title: "", image: nil, identifier: UIMenu.Identifier("\(info.id).show"), options: .displayInline, children: [command])
            builder.insertChild(menu, atEndOfMenu: .window)
        }
    }

    func buildAddLocal(with builder: UIMenuBuilder) {
        let command = UIKeyCommand(title: "Add Local Repos", image: nil, action: #selector(addLocalRepos), input: "O", modifierFlags: .command, propertyList: nil)
        let menu = UIMenu(title: "", image: nil, identifier: UIMenu.Identifier("\(info.id).addLocal"), options: .displayInline, children: [command])
        builder.insertChild(menu, atStartOfMenu: .file)
    }
    
    func replacePreferences(with builder: UIMenuBuilder) {
        let command = UIKeyCommand(title: "Preferences…", image: nil, action: #selector(showPreferences), input: ",", modifierFlags: .command, propertyList: nil)
        let menu = UIMenu(title: "", image: nil, identifier: UIMenu.Identifier("\(info.id).showPreferences"), options: .displayInline, children: [command])
        builder.insertSibling(menu, beforeMenu: .close)
    }

    func replaceQuit(with builder: UIMenuBuilder) {
        let command = UIKeyCommand(title: "Quit \(info.name)", image: nil, action: #selector(handleQuit), input: "Q", modifierFlags: .command, propertyList: nil)
        let menu = UIMenu(title: "", image: nil, identifier: UIMenu.Identifier("\(info.id).handleQuit"), options: .displayInline, children: [command])
        builder.replace(menu: .quit, with: menu)
    }

    @IBAction func handleQuit() {
        ensureBridgeLoaded()?.handleQuit(self)
    }
    
    @IBAction func showPreferences() {
        sheetController.show() {
            PreferencesView()
        }
    }
    
    @IBAction func addLocalRepos() {
        let picker = filePickerClass.init(forOpeningFolderStartingIn: nil) { urls in
            self.model.add(fromFolders: urls)
        }
        presentPicker(picker)
    }
  
}

extension MobileApplication: AppKitBridgeDelegate {
    func windowToIntercept() -> String {
        return info.name
    }
    
    func itemCount() -> Int {
        return model.count
    }
    
    func name(forItem item: Int) -> String {
        return status.name(forRepoWithIndex: item)
    }
    
    func status(forItem item: Int) -> ItemStatus {
        let state = status.state(forRepoWithIndex: item)
        return status(for: state)
    }
    
    func selectItem(_ item: Int) {
        let repo = status.repo(withIndex: item)
        Application.native.open(url: repo.githubURL())
    }
    
    func addItem() {
        editNewRepo()
    }
    
    func toggleEditing() -> Bool {
        context.settings.toggleEditing()
    }
}
