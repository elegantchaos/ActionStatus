// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

open class Updater: ObservableObject {
    @Published public var progress: Double = 0
    @Published public var status: String = ""
    @Published public var hasUpdate: Bool = false

    public init() {
    }
    
    open func installUpdate() { }
    open func skipUpdate() { }
    open func ignoreUpdate() { }
}

