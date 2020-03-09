// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import SwiftUIExtensions
import ActionStatusCore

#if canImport(UIKit)
struct AddButton: View {
    @EnvironmentObject var viewState: ViewState
    @EnvironmentObject var model: Model
    
    var body: some View {
        Button(action: { self.model.addRepo() } ) {
            SystemImage("plus.circle").font(.title)
        }
        .disabled(!viewState.isEditing)
        .opacity(viewState.isEditing ? 1.0 : 0.0)
    }
}
#endif

struct NoReposView: View {
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("No Repos Configured").font(.title)
            Spacer()
            Button(action: action) {
                Text("Configure a repo to begin monitoring it.")
            }
        }
    }
}

struct FooterView: View {
    @EnvironmentObject var updater: Updater
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack(spacing: 10) {
            Text(statusText).statusStyle()
            if hasUpdate {
                SparkleView(updater: updater)
            }
            if showProgress {
                GeometryReader { geometryReader in
                    SparkleProgressView(updater: self.updater).frame(width: geometryReader.size.width * 0.25)
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
