// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


import UIKit
import SwiftUI
import Logger

@UIApplicationMain
class AppDelegate: AppCommon {
    var appKitBridge: AppKitBridge? = nil
    var filePicker: UIDocumentPickerViewController?
    
    override func setUp(withOptions options: LaunchOptions) {
        loadBridge()
        model.block = { self.updateBridge() }

        super.setUp(withOptions: options)
    }
    
    override func didSetup(_ window: UIWindow) {
        if let bridge = appKitBridge {
            bridge.setup(withSparkle: sparkleDriver, capturingWindowNamed: info.name, dataSource: self)
        }
    }
    
    override func applySettings() {
        super.applySettings()
        updateBridge()
    }
    
    fileprivate func updateBridge() {
        appKitBridge?.showInMenu = UserDefaults.standard.bool(forKey: "ShowInMenu")
        appKitBridge?.showInDock = UserDefaults.standard.bool(forKey: "ShowInDock")
        appKitBridge?.passing = model.failingCount == 0
    }
    
    fileprivate func loadBridge() {
        if let bridgeURL = Bundle.main.url(forResource: "AppKitBridge", withExtension: "bundle"), let bundle = Bundle(url: bridgeURL) {
            if let cls = bundle.principalClass as? NSObject.Type {
                if let instance = cls.init() as? AppKitBridge {
                    appKitBridge = instance
                    sparkleDriver = ActionStatusSparkleDriver()
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
        pickFilesToOpen(types: ["public.folder"]) { urls in
            self.model.add(fromFolders: urls)
        }
    }
    
    class CustomPicker: UIDocumentPickerViewController, UIDocumentPickerDelegate {
        typealias Completion = ([URL]) -> Void
        
        let cleanupURLS: [URL]
        let completion: Completion?
        
        init(url: URL, in mode: UIDocumentPickerMode, completion: Completion? = nil) {
            self.cleanupURLS = [url]
            self.completion = completion
            super.init(url: url, in: mode)
            delegate = self
            modalPresentationStyle = .overFullScreen
        }

        init(documentTypes allowedUTIs: [String], in mode: UIDocumentPickerMode, completion: Completion? = nil) {
            self.cleanupURLS = []
            self.completion = completion
            super.init(documentTypes: allowedUTIs, in: mode)
            delegate = self
            modalPresentationStyle = .overFullScreen
        }
        
        required init?(coder: NSCoder) {
            fatalError()
        }
        
        func cleanup() {
            for url in cleanupURLS {
                try? FileManager.default.removeItem(at: url)
            }
            AppDelegate.shared.filePicker = nil
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            cleanup()
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            completion?(urls)
            cleanup()
        }
    }

    func pickFilesToOpen(types: [String], completion: CustomPicker.Completion? = nil) {
        let controller = CustomPicker(documentTypes: types, in: .open, completion: completion)
        rootController?.present(controller, animated: true) {
        }
        filePicker = controller
    }
    
    func pickFile(url: URL) {
        let controller = CustomPicker(url: url, in: UIDocumentPickerMode.moveToService)
        rootController?.present(controller, animated: true) {
        }
        filePicker = controller
    }
}

extension AppDelegate: MenuDataSource {
    func itemCount() -> Int {
        return model.items.count
    }
    
    func name(forItem item: Int) -> String {
        return model.items[item].name
    }
    
    func status(forItem item: Int) -> ItemStatus {
        switch model.items[item].state {
            case .unknown: return .unknown
            case .failing: return .failed
            case .passing: return .succeeded
        }
    }
    
    func selectItem(_ item: Int) {
        let repo = model.items[item]
        if let url = URL(string: "https://github.com/\(repo.owner)/\(repo.name)/actions?query=workflow%3A\(repo.workflow)") {
            UIApplication.shared.open(url)
        }
    }
    
    func handlePreferences() {
        
    }
}
