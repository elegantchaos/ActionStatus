// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit
import UniformTypeIdentifiers

public typealias FilePickerCompletion = ([URL]) -> Void

public protocol FilePicker: UIViewController {
  init(forOpeningDocumentTypes: [UTType], startingIn: URL?, completion: FilePickerCompletion?)
}

public extension FilePicker {
  init(forOpeningFolderStartingIn startURL: URL?, completion: FilePickerCompletion?) {
    self.init(forOpeningDocumentTypes: [.folder], startingIn: startURL, completion: completion)
  }
}
