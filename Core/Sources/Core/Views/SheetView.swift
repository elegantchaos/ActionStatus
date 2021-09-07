// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import SwiftUIExtensions


public struct SheetView<Content>: View where Content: View {
    typealias Action = () -> Void
    
    init(_ title: String, shortTitle: String, cancelAction: Action? = nil, cancelLabel: String = "Cancel", doneAction: @escaping Action, doneLabel: String = "Done", @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.shortTitle = shortTitle
        self.cancelAction = cancelAction
        self.cancelLabel = cancelLabel
        self.doneAction = doneAction
        self.doneLabel = doneLabel
        self.content = content
    }
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    let title: String
    let shortTitle: String
    let cancelAction: Action?
    let cancelLabel: String
    let doneAction: Action
    let doneLabel: String
    let content: () -> Content
    
    public var body: some View {
        NavigationView {
            AlignedLabelContainer {
                content()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    let title = (horizontalSizeClass == .compact) ? shortTitle : self.title
                    Text(title)
                        .accessibility(identifier: "formHeader")
                }
                
                #if targetEnvironment(macCatalyst)
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                #endif
                
                ToolbarItem(placement: cancelPlacement) {
                    if let action = cancelAction {
                        CancelButton(label: cancelLabel, action: action)
                    }
                }
                
                ToolbarItem(placement: confirmationPlacement) {
                    Button(action: doneAction) { Text(doneLabel) }
                        .accessibility(identifier: "done")
                        .shim.defaultShortcut()
                }
            }
        }
    }

    #if targetEnvironment(macCatalyst)
    let cancelPlacement = ToolbarItemPlacement.bottomBar
    let confirmationPlacement = ToolbarItemPlacement.bottomBar

    struct CancelButton: View {
        let label: String
        let action: Action
        
        var body: some View {
            Button(action: action) { Text(label) }
                .accessibility(identifier: "cancel")
                .keyboardShortcut(.cancelAction)
                .padding(.trailing)
        }
    }

    #else

    let cancelPlacement = ToolbarItemPlacement.cancellationAction
    let confirmationPlacement = ToolbarItemPlacement.confirmationAction

    struct CancelButton: View {
        let label: String
        let action: Action!
        
        var body: some View {
            Button(action: action!) { Text(label) }
                .accessibility(identifier: "cancel")
                .shim.cancelShortcut()
        }
    }

    #endif

}

