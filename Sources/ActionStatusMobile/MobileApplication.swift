// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


import ActionStatusCore
import Combine
import Logger
import SwiftUI
import UIKit

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
    var editingSubscriber: AnyCancellable?
    
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

    override func didRefresh() {
        super.didRefresh()
        updateBridge()
    }
    
    override func setUp(withOptions options: LaunchOptions) {
        loadSparkle()
        loadBridge()
        
        UserDefaults.standard.register(defaults: [
            .showInMenuKey: true,
            .showInDockKey: true
            ]
        )

        editingSubscriber = viewState.$isEditing.sink() { _ in
            DispatchQueue.main.async {
                self.updateBridge()
            }
        }
        
        super.setUp(withOptions: options)
    }
    
    override func didSetUp(_ window: UIWindow) {
        if let bridge = appKitBridge {
            bridge.setup(with: self)
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
        appKitBridge?.showAddButton = viewState.isEditing
        appKitBridge?.passing = (model.failing == 0)
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
    
    fileprivate func loadBridge() {
        if let bridgeURL = Bundle.main.url(forResource: "AppKitBridge", withExtension: "bundle"), let bundle = Bundle(url: bridgeURL) {
            if let cls = bundle.principalClass as? NSObject.Type {
                if let instance = cls.init() as? AppKitBridge {
                    #if canImport(SparkleBridgeClient)
                    instance.showUpdates = sparkleEnabled
                    #endif
                    appKitBridge = instance
                }
            }
        }
    }
    
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        
        if builder.system == .main {
            builder.remove(menu: .services)
            builder.remove(menu: .format)
            builder.remove(menu: .toolbar)

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

extension MobileApplication: AppKitBridgeDelegate {
    func windowToIntercept() -> String {
        return info.name
    }
    
    func itemCount() -> Int {
        return model.itemIdentifiers.count
    }
    
    func name(forItem item: Int) -> String {
        let id = model.itemIdentifiers[item]
        return model.repo(withIdentifier: id)?.name ?? ""
    }
    
    func status(forItem item: Int) -> ItemStatus {
        let id = model.itemIdentifiers[item]
        if let state = model.repo(withIdentifier: id)?.state, let status = ItemStatus(rawValue: state.rawValue) {
            return status
        }
        
        return .unknown
    }
    
    func selectItem(_ item: Int) {
        let id = model.itemIdentifiers[item]
        if let repo = model.repo(withIdentifier: id) {
            Application.shared.openGithub(with: repo)
        }
    }
    
    func addItem() {
        sheetController.show() {
            EditView(repoID: nil)
        }
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
