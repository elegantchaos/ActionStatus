// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 06/03/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit

class CustomPicker: UIViewController, FilePicker {
    required init(forOpeningDocumentTypes: [String], startingIn: URL?, completion: FilePickerCompletion?) {
        super.init(nibName: nil, bundle: nil)
    }

    required init(forOpeningFolderStartingIn: URL?, completion: FilePickerCompletion?) {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
