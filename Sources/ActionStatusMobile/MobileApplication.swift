// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


import UIKit
import SwiftUI
import Logger

#if canImport(SparkleBridgeClient)
import SparkleBridgeClient
#endif

fileprivate extension String {
    static let showInMenuKey = "ShowInMenu"
    static let showInDockKey = "ShowInDock"
}

extension Application {
    class var shared: MobileApplication {
        UIApplication.shared.delegate as! MobileApplication
    }
}

@UIApplicationMain
class MobileApplication: Application {
    var appKitBridge: AppKitBridge? = nil
    var sparkleBridge: SparkleBridgePlugin? = nil

    override func makeUpdater() -> Updater {
        return SparkleUpdater()
    }
    
    override var filePickerClass: FilePicker.Type { return MobileFilePicker.self }

    override func setUp(withOptions options: LaunchOptions) {
        loadBridge()
        loadSparkle()
        model.block = { self.updateBridge() }
        
        UserDefaults.standard.register(defaults: [
            .showInMenuKey: true,
            .showInDockKey: true
            ]
        )

        super.setUp(withOptions: options)
    }
    
    override func didSetUp(_ window: UIWindow) {
        if let bridge = appKitBridge {
            bridge.setupCapturingWindowNamed(info.name, dataSource: self)
        }
        super.didSetUp(window)
    }
    
    override func applySettings() {
        super.applySettings()
        updateBridge()
        
        settingsChannel.log("\(String.showInMenuKey) is \(appKitBridge?.showInMenu ?? false)")
        settingsChannel.log("\(String.showInDockKey) is \(appKitBridge?.showInDock ?? false)")
    }

    fileprivate func updateBridge() {
        appKitBridge?.showInMenu = UserDefaults.standard.bool(forKey: .showInMenuKey)
        appKitBridge?.showInDock = UserDefaults.standard.bool(forKey: .showInDockKey)
        appKitBridge?.passing = model.failingCount == 0
    }
    
    fileprivate func loadSparkle() {
        #if canImport(SparkleBridgeClient)
        if let updater = updater as? SparkleUpdater {
            let result = SparkleBridgeClient.load(with: updater.driver)
            switch result {
                case .success(let plugin):
                    sparkleBridge = plugin
                case .failure(let error):
                    print(error)
            }
        }
        #endif
    }
    
    fileprivate func loadBridge() {
        if let bridgeURL = Bundle.main.url(forResource: "AppKitBridge", withExtension: "bundle"), let bundle = Bundle(url: bridgeURL) {
            if let cls = bundle.principalClass as? NSObject.Type {
                if let instance = cls.init() as? AppKitBridge {
                    appKitBridge = instance
                }
            }
        }
    }
    
    override func buildMenu(with builder: UIMenuBuilder) {
        if builder.system == .main {
            buildShowStatus(with: builder)
            buildAddLocal(with: builder)
        }
        
        next?.buildMenu(with: builder)
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

    @IBAction func addLocalRepos() {
        let picker = filePickerClass.init(forOpeningFolderStartingIn: nil) { urls in
            self.model.add(fromFolders: urls)
        }
        presentPicker(picker)
    }
    
    func presentPicker(_ picker: FilePicker) {
        rootController?.present(picker, animated: true) {
        }
        filePicker = picker
    }
}

extension MobileApplication: MenuDataSource {
    func itemCount() -> Int {
        return model.itemIdentifiers.count
    }
    
    func name(forItem item: Int) -> String {
        let id = model.itemIdentifiers[item]
        return model.repo(withIdentifier: id)?.name ?? ""
    }
    
    func status(forItem item: Int) -> ItemStatus {
        let id = model.itemIdentifiers[item]
        switch model.repo(withIdentifier: id)?.state ?? .unknown {
            case .unknown: return .unknown
            case .failing: return .failed
            case .passing: return .succeeded
        }
    }
    
    func selectItem(_ item: Int) {
        let id = model.itemIdentifiers[item]
        if let repo = model.repo(withIdentifier: id) {
            Application.shared.openGithub(with: repo)
        }
    }
    
    func checkForUpdates() {
        #if canImport(SparkleBridgeClient)
        sparkleBridge?.checkForUpdates()
        #endif
    }
}
