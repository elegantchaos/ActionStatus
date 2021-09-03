// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SheetController
import SwiftUI
import SwiftUIExtensions

public struct FooterView: View {
    @EnvironmentObject var updater: Updater
    @EnvironmentObject var status: RepoState
    @EnvironmentObject var sheetController: SheetController
    @EnvironmentObject var focusThingy: FocusThingy

    let namespace: Namespace.ID
    
    #if os(tvOS)
    let focus: FocusState<Focus?>.Binding
    #endif
    
    public init(namespace: Namespace.ID, focus: FocusState<Focus?>.Binding) {
        self.namespace = namespace
        self.focus = focus
    }
    
    public var body: some View {
        VStack(spacing: 10) {
            if !updater.status.isEmpty {
                Text(updater.status)
                    .statusStyle()
            } else {
                HStack(spacing: 8) {
                    Text("Monitoring \(status.sortedRepos.count) repos.")
                    if status.failing > 0 {
                        HStack(spacing: 4) {
                            StatusIcon("StatusFailing")
                            Text("\(status.failing) failing.")
                        }
                    }

                    if status.queued > 0 {
                        HStack(spacing: 4) {
                            StatusIcon("StatusQueued")
                            Text("\(status.queued) queued.")
                        }
                    }

                    if status.running > 0 {
                        HStack(spacing: 4) {
                            StatusIcon("StatusRunning")
                            Text("\(status.running) running.")
                        }
                    }

                    if status.unreachable > 0 {
                        HStack(spacing: 4) {
                            StatusIcon("StatusUnknown")
                            Text("\(status.unreachable) unreachable.")
                        }
                    }
                    
                    #if os(tvOS)
                    if #available(tvOS 15.0, *) {
                        PreferencesButton()
                            .prefersDefaultFocus(in: namespace)
                            .focused(focus, equals: .prefs)
                    }
                    #endif
                }
                .statusStyle()
            }
            
            if hasUpdate {
                SparkleView()
            }

            if showProgress {
                GeometryReader { geometryReader in
                    SparkleProgressView().frame(width: geometryReader.size.width * 0.25, height: 16)
                }
            }
        }
        .padding()
    }
    
    var hasUpdate: Bool {
        return updater.hasUpdate
    }
    
    var showProgress: Bool {
        return (updater.progress > 0.0) && (updater.progress < 1.0)
    }
    
}
