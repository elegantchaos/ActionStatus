// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit

public typealias FilePickerCompletion = ([URL]) -> Void

public protocol FilePicker: UIViewController {
    init(forOpeningDocumentTypes: [String], startingIn: URL?, completion: FilePickerCompletion?)
}

public extension FilePicker {
    init(forOpeningFolderStartingIn startURL: URL?, completion: FilePickerCompletion?) {
        self.init(forOpeningDocumentTypes: ["public.folder"], startingIn: startURL, completion: completion)
    }
}
