// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit
import SwiftUI

extension Application {
    class var shared: TVApplication {
        UIApplication.shared.delegate as! TVApplication
    }
}

@UIApplicationMain
class TVApplication: Application {
    override init() {
        super.init(updater: Updater())
    }
}

