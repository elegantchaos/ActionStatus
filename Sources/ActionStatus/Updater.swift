// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

class Updater: ObservableObject {
    @Published var progress: Double = 0
    @Published var status: String = ""
    @Published var hasUpdate: Bool = false

    func installUpdate() { }
    func skipUpdate() { }
    func ignoreUpdate() { }
}

