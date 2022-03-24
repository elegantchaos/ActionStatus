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

    lazy var appKitBridge: AppKitBridge? = loadBridge()
    var editingSubscriber: AnyCancellable?
    var updateTimer: Timer?
    
    override var filePickerClass: FilePicker.Type { return MobileFilePicker.self }

    override func setUp(withOptions options: LaunchOptions, completion: @escaping SetupCompletion) {
        super.setUp(withOptions: options) { [self] options in
            
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
        
        settingsChannel.log("\(String.showInMenuKey) is \(appKitBridge?.showInMenu ?? false)")
        settingsChannel.log("\(String.showInDockKey) is \(appKitBridge?.showInDock ?? false)")
    }

    override func reveal(url: URL) {
        if let bridge = appKitBridge {
            bridge.reveal(inFinder: url)
        } else {
            super.reveal(url: url)
        }
    }
    
    fileprivate func status(for state: Repo.State) -> ItemStatus {
        return ItemStatus(rawValue: state.rawValue) ?? .unknown
    }

    fileprivate func updateBridge() {
        appKitBridge?.showInMenu = UserDefaults.standard.bool(forKey: .showInMenuKey)
        appKitBridge?.showInDock = UserDefaults.standard.bool(forKey: .showInDockKey)
        appKitBridge?.showAddButton = context.settings.isEditing
        
        let combined = status.combinedState
        let index = Int(Date.timeIntervalSinceReferenceDate / .statusCycleInterval) % combined.count
        let status = self.status(for: self.status.combinedState[index])
        appKitBridge?.status = status
    }
    
    fileprivate func loadBridge() -> AppKitBridge? {
        if let bridgeURL = Bundle.main.url(forResource: "AppKitBridge", withExtension: "bundle"), let bundle = Bundle(url: bridgeURL) {
            if let cls = bundle.principalClass as? NSObject.Type {
                if let instance = cls.init() as? AppKitBridge {
                    instance.setup(with: self)
                    return instance
                }
            }
        }
        
        return nil
    }
    
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        
        if builder.system == .main {
            builder.remove(menu: .services)
            builder.remove(menu: .format)
            builder.remove(menu: .toolbar)

            replacePreferences(with: builder)
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
        if let bridge = appKitBridge {
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
