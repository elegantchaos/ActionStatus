// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import SwiftUIExtensions
import ActionStatusCore

struct FooterView: View {
    @EnvironmentObject var updater: Updater
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack(spacing: 10) {
            if !updater.status.isEmpty {
                Text(updater.status).statusStyle()
            } else {
                HStack(spacing: 8) {
                    Text("Monitoring \(model.itemIdentifiers.count) repos.")
                    if model.failing > 0 {
                        HStack(spacing: 4) {
                            SystemImage("exclamationmark.triangle.fill").foregroundColor(.red)
                            Text("\(model.failing) failing.")
                        }
                    }
                    
                    if model.unreachable > 0 {
                        HStack(spacing: 4) {
                            SystemImage("exclamationmark.triangle.fill").foregroundColor(.yellow)
                            Text("\(model.unreachable) unreachable.")
                        }
                    }
                }.statusStyle()
            }
            
            if hasUpdate {
                SparkleView()
            }

            if showProgress {
                GeometryReader { geometryReader in
                    SparkleProgressView().frame(width: geometryReader.size.width * 0.25, height: 16)
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
        guard updater.status.isEmpty else {
            return updater.status
        }
        
        var text = "Monitoring \(model.itemIdentifiers.count) repos."
        if model.failing > 0 {
            text += " \(model.failing) failing."
        }
        
        if model.unreachable > 0 {
            text += " \(model.unreachable) unreachable."
        }
        
        return text
    }
    
}
