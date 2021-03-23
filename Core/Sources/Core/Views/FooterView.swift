// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SheetController
import SwiftUI
import SwiftUIExtensions

public struct FooterView: View {
    @EnvironmentObject var updater: Updater
    @EnvironmentObject var status: Status
    @EnvironmentObject var sheetController: SheetController
    
    public init() {
    }
    
    public var body: some View {
        VStack(spacing: 10) {
            if !updater.status.isEmpty {
                Text(updater.status).statusStyle()
            } else {
                HStack(spacing: 8) {
                    Text("Monitoring \(status.sortedRepos.count) repos.")
                    if status.failing > 0 {
                        HStack(spacing: 4) {
                            SystemImage("exclamationmark.triangle.fill").foregroundColor(.red)
                            Text("\(status.failing) failing.")
                        }
                    }

                    if status.queued > 0 {
                        HStack(spacing: 4) {
                            SystemImage("ellipsis").foregroundColor(.black)
                            Text("\(status.queued) queued.")
                        }
                    }

                    if status.running > 0 {
                        HStack(spacing: 4) {
                            SystemImage("arrow.triangle.2.circlepath.fill").foregroundColor(.black)
                            Text("\(status.running) running.")
                        }
                    }

                    if status.unreachable > 0 {
                        HStack(spacing: 4) {
                            SystemImage("exclamationmark.triangle.fill").foregroundColor(.yellow)
                            Text("\(status.unreachable) unreachable.")
                        }
                    }
                    
                    PreferencesButton()
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
}
