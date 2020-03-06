// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit

typealias FilePickerCompletion = ([URL]) -> Void

protocol FilePicker: UIViewController {
    init(forOpeningDocumentTypes: [String], startingIn: URL?, completion: FilePickerCompletion?)
    init(forOpeningFolderStartingIn: URL?, completion: FilePickerCompletion?)
}
