// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(iOS)
  import Core
  import SwiftUI
  import UIKit

  class MobileEngine: Engine {
    override class var shared: MobileEngine {
      UIApplication.shared.delegate as! MobileEngine
    }

    override var filePickerClass: FilePicker.Type { return MobileFilePicker.self }

    @objc func showHelp(_ sender: Any) {
      if let url = URL(string: "https://actionstatus.elegantchaos.com/help") {
        UIApplication.shared.open(url)
      }
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
