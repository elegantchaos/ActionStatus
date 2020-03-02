// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit

extension Application {
    class var shared: TVApplication {
        UIApplication.shared.delegate as! TVApplication
    }
}

@UIApplicationMain
class TVApplication: Application {
    let stubUpdater = Updater()
    func makeContentView() -> some View {
        let app = Application.shared
        return ContentView(updater: stubUpdater, repos: app.model)
    }
}

