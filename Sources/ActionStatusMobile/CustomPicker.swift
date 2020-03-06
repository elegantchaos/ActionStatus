// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit
import Foundation

class CustomPicker: UIDocumentPickerViewController {
    typealias Completion = ([URL]) -> Void
    
    let cleanupURLS: [URL]
    let completion: Completion?

    
    required init(forOpeningFolderStartingIn startURL: URL?, completion: FilePickerCompletion?) {
        self.cleanupURLS = []
        self.completion = completion
        super.init(documentTypes: ["public.folder"], in: .open) // kUTTypeFolder
        setup(startURL: startURL)
    }
    
    required init(forOpeningDocumentTypes types: [String], startingIn startURL: URL? = nil, completion: FilePickerCompletion? = nil) {
        self.cleanupURLS = []
        self.completion = completion
        super.init(documentTypes: types, in: .open)
        setup(startURL: startURL)
    }
    
    func setup(startURL: URL?) {
        if let url = startURL {
            directoryURL = url
        }
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
    }


}

extension CustomPicker: FilePicker {
}

extension CustomPicker: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        completion?([])
        cleanup()
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        completion?(urls)
        cleanup()
    }
}

