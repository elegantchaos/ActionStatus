// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct SparkleView: View {
    @EnvironmentObject var updater: Updater
    
    var body: some View {
        HStack {
            Button(action: updater.installUpdate) { Text("Update") }
            Button(action: updater.skipUpdate) { Text("Skip") }
            Button(action: updater.ignoreUpdate) { Text("Later") }
        }.statusStyle()
    }
}
