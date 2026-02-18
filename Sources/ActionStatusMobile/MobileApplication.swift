// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(iOS)
  import Core
  import SwiftUI
  import UIKit

  class MobileApplication: Engine {
    override class var shared: MobileApplication {
      UIApplication.shared.delegate as! MobileApplication
    }

    override var filePickerClass: FilePicker.Type { return MobileFilePicker.self }

    override func buildMenu(with builder: UIMenuBuilder) {
      super.buildMenu(with: builder)

      if builder.system == .main {
        builder.remove(menu: .services)
        builder.remove(menu: .format)
        builder.remove(menu: .toolbar)

        replacePreferences(with: builder)
        buildAddLocal(with: builder)
      }

      next?.buildMenu(with: builder)
    }

    @objc func showHelp(_ sender: Any) {
      if let url = URL(string: "https://actionstatus.elegantchaos.com/help") {
        UIApplication.shared.open(url)
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
      sheetController.show {
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
#endif
