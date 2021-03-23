// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


import Core
import Combine
import Logger
import SwiftUI
import UIKit

#if canImport(SparkleBridgeClient)
import SparkleBridgeClient
#endif

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
    
    #if canImport(SparkleBridgeClient)
    let sparkleEnabled = Bundle.main.hasFramework(named: "SparkleBridgeClient")
    var sparkleBridge: SparkleBridgePlugin? = nil

    override func makeUpdater() -> Updater {
        if sparkleEnabled {
            return SparkleUpdater()
        } else {
            return super.makeUpdater()
        }
    }
    #endif
    
    override var filePickerClass: FilePicker.Type { return MobileFilePicker.self }

    override func setUp(withOptions options: LaunchOptions, completion: @escaping SetupCompletion) {
        super.setUp(withOptions: options) { [self] options in
            loadSparkle()
            
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

    fileprivate func status(for state: Repo.State) -> ItemStatus {
        return ItemStatus(rawValue: state.rawValue) ?? .unknown
    }

    fileprivate func updateBridge() {
        appKitBridge?.showInMenu = UserDefaults.standard.bool(forKey: .showInMenuKey)
        appKitBridge?.showInDock = UserDefaults.standard.bool(forKey: .showInDockKey)
        appKitBridge?.showAddButton = viewState.isEditing
        
        let combined = status.combinedState
        let index = Int(Date.timeIntervalSinceReferenceDate / .statusCycleInterval) % combined.count
        let status = status(for: self.status.combinedState[index])
        appKitBridge?.status = status
    }
    
    fileprivate func loadSparkle() {
        #if canImport(SparkleBridgeClient)
        if let updater = updater as? SparkleUpdater {
            let result = SparkleBridgeClient.load(with: updater.driver)
            switch result {
                case .success(let plugin):
                    sparkleBridge = plugin
                    sparkleBridge?.checkForUpdates()
                case .failure(let error):
                    print(error)
                    self.updater = Updater()
            }
        }
        #endif
    }
    
    fileprivate func loadBridge() -> AppKitBridge? {
        if let bridgeURL = Bundle.main.url(forResource: "AppKitBridge", withExtension: "bundle"), let bundle = Bundle(url: bridgeURL) {
            if let cls = bundle.principalClass as? NSObject.Type {
                if let instance = cls.init() as? AppKitBridge {
                    #if canImport(SparkleBridgeClient)
                    instance.showUpdates = sparkleEnabled
                    #endif
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
            buildCheckForUpdates(with: builder)
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

    func buildCheckForUpdates(with builder: UIMenuBuilder) {
        #if canImport(SparkleBridgeClient)
        if sparkleEnabled {
            let command = UIKeyCommand(title: "Check For Updates…", image: nil, action: #selector(checkForUpdates), input: "", modifierFlags: [], propertyList: nil)
            builder.replaceChildren(ofMenu: .about) { (children) -> [UIMenuElement] in
                return children + [command]
            }
        }
        #endif
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
        builder.insertSibling(menu, afterMenu: .preferences)
        builder.replace(menu: .preferences, with: menu)
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
        Application.native.openGithub(with: repo)
    }
    
    func addItem() {
        editNewRepo()
    }
    
    func checkForUpdates() {
        #if canImport(SparkleBridgeClient)
        sparkleBridge?.checkForUpdates()
        #endif
    }
    
    func toggleEditing() -> Bool {
        viewState.isEditing = !viewState.isEditing
        return viewState.isEditing
    }
}
