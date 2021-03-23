// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if !os(tvOS)

import UIKit
import UniformTypeIdentifiers

public class MobileFilePicker: UIDocumentPickerViewController, FilePicker {
    typealias Completion = ([URL]) -> Void
    
    let cleanupURLS: [URL]
    let completion: Completion?

    public required init(forOpeningDocumentTypes types: [UTType], startingIn startURL: URL? = nil, completion: FilePickerCompletion? = nil) {
        self.cleanupURLS = []
        self.completion = completion
        super.init(forOpeningContentTypes: types)
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


extension MobileFilePicker: UIDocumentPickerDelegate {
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        completion?([])
        cleanup()
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        completion?(urls)
        cleanup()
    }
}

#endif
