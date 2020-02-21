// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


import UIKit
import SwiftUI

@UIApplicationMain
class AppDelegate: AppCommon {
    var appKitBridge: AppKitBridge? = nil
    var filePicker: UIDocumentPickerViewController?

    override func setup(withOptions options: LaunchOptions) {
        loadBridge()
        repos.block = { self.refreshBridge() }

        super.setup(withOptions: options)
    }
    
    override func didSetup(_ window: UIWindow) {
        appKitBridge?.didSetup(window)
    }
    
    fileprivate func refreshBridge() {
        appKitBridge?.passing = repos.failingCount == 0
    }
    
    fileprivate func loadBridge() {
        if let bridgeURL = Bundle.main.url(forResource: "AppKitBridge", withExtension: "bundle"), let bundle = Bundle(url: bridgeURL) {
            if let cls = bundle.principalClass as? NSObject.Type {
                if let instance = cls.init() as? AppKitBridge {
                    appKitBridge = instance
                    instance.setup()
                    instance.setDataSource(self)
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
            let command = UIKeyCommand(title: "Show Status Window", image: nil, action: bridge.showHandler(), input: "0", modifierFlags: .command, propertyList: nil)
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
            
            
            let fm = FileManager.default
            for url in urls {
                if
                    let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue),
                    let items = try? fm.contentsOfDirectory(at: url, includingPropertiesForKeys: [], options: []) {
                    for item in items {
                        if item.lastPathComponent == ".git" {
                            print(item.deletingLastPathComponent())
                            if let config = try? String(contentsOf: item.appendingPathComponent("config")) {
                                let tweaked = config.replacingOccurrences(of: "git@github.com:", with: "https://github.com/")
                                let range = NSRange(location: 0, length: tweaked.count)
                                for result in detector.matches(in: tweaked, options: [], range: range) {
                                    if let url = result.url, url.scheme == "https", url.host == "github.com" {
                                        let repo = url.deletingPathExtension().lastPathComponent
                                        let owner = url.deletingLastPathComponent().lastPathComponent
                                        self.addRepo(name: repo, owner: owner)
                                    }
                                }
//                                let lines = config.split(separator: "\n").filter({ $0.contains("github.com") })
//                                for line in lines {
//                                    if line.contains("git@github.com:") {
//                                        let spec = line.split(separator: ":")[1].split(separator: "/")
//                                        self.addRepo(name: String(spec[0]), owner: String(spec[1]))
//                                    } else if line.contains("https://github.com/") {
//                                        let spec = line.split(separator: "/")
//                                        self.addRepo(name: String(spec[3]), owner: String(spec[4]))
//                                    }
//                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func addRepo(name: String, owner: String) {
        print(name)
        print(owner)
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
        return repos.items.count
    }
    
    func name(forItem item: Int) -> String {
        return repos.items[item].name
    }
    
    func status(forItem item: Int) -> ItemStatus {
        switch repos.items[item].state {
            case .unknown: return .unknown
            case .failing: return .failed
            case .passing: return .succeeded
        }
    }
    
    func selectItem(_ item: Int) {
        let repo = repos.items[item]
        if let url = URL(string: "https://github.com/\(repo.owner)/\(repo.name)/actions?query=workflow%3A\(repo.workflow)") {
            UIApplication.shared.open(url)
        }
    }
    
    func handlePreferences() {
        
    }
}


