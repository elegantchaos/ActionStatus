// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import ActionStatusCore

struct FooterView: View {
    @EnvironmentObject var updater: Updater
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack(spacing: 10) {
            Text(statusText).statusStyle()
            if hasUpdate {
                SparkleView()
            }
            if showProgress {
                GeometryReader { geometryReader in
                    SparkleProgressView().frame(width: geometryReader.size.width * 0.25)
                }
            }
        }.padding()
    }
    
    var hasUpdate: Bool {
        return updater.hasUpdate
    }
    
    var showProgress: Bool {
        return (updater.progress > 0.0) && (updater.progress < 1.0)
    }

    var statusText: String {
         if updater.status.isEmpty {
             return "Monitoring \(model.itemIdentifiers.count) repos."
         } else {
             return updater.status
         }
     }


}
