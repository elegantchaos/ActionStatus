// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(iOS)

import Foundation
import UIKit

public extension Engine {
  func presentPicker(_ picker: FilePicker) {
    rootController?.present(picker, animated: true) {
    }
    filePicker = picker
  }
  
  var filePickerClass: FilePicker.Type { return MobileFilePicker.self }

  func showHelp(_ sender: Any) {
    if let url = URL(string: "https://actionstatus.elegantchaos.com/help") {
      UIApplication.shared.open(url)
    }
  }

  func showPreferences() {
    sheetService.presentedSheet = .preferences
  }

  @IBAction func addLocalRepos() {
    let picker = filePickerClass.init(forOpeningFolderStartingIn: nil) { urls in
      self.modelService.add(fromFolders: urls)
    }
    presentPicker(picker)
  }

}

#endif
