// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import SwiftUIExtensions


public struct SheetView<Content>: View where Content: View {
    typealias Action = () -> Void
    
    init(_ title: String, cancelAction: Action? = nil, cancelLabel: String = "Cancel", doneAction: @escaping Action, doneLabel: String = "Done", @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.cancelAction = cancelAction
        self.cancelLabel = cancelLabel
        self.doneAction = doneAction
        self.doneLabel = doneLabel
        self.content = content
    }
    
    let title: String
    let cancelAction: Action?
    let cancelLabel: String
    let doneAction: Action
    let doneLabel: String
    let content: () -> Content
    
    public var body: some View {
        AlignedLabelContainer {
            VStack {
                HStack(alignment: .center) {
                    HStack {
                        #if !targetEnvironment(macCatalyst)
                        if cancelAction != nil {
                            Button(action: cancelAction!) { Text(cancelLabel) }
                                .accessibility(identifier: "cancel")
                        }
                        #endif
                        Spacer()
                    }

                    Text(title)
                        .font(.headline)
                        .fixedSize()
                        .accessibility(identifier: "formHeader")

                    HStack {
                        Spacer()
                        #if !targetEnvironment(macCatalyst)
                        Button(action: doneAction) { Text(doneLabel) }
                            .accessibility(identifier: "done")
                        #endif
                    }
                }.padding([.leading, .trailing, .top], 20)
                
                content()
                
                #if targetEnvironment(macCatalyst)
                
                HStack(alignment: .center) {
                    Spacer()
                    if let action = cancelAction {
                        Button(action: action) { Text(cancelLabel) }
                            .accessibility(identifier: "cancel")
                            .keyboardShortcut(.cancelAction)
                    }
                    Button(action: doneAction) { Text(doneLabel) }
                        .accessibility(identifier: "done")
                        .keyboardShortcut(.defaultAction)
                }
                .padding([.leading, .trailing, .top], 20)
                #endif
            }
        }
    }
}
