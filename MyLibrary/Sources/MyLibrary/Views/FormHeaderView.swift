// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct FormHeaderView: View {
    typealias Action = () -> Void
    let cancelLabel: String
    let cancelAction: Action?
    let doneLabel: String
    let doneAction: Action?
    let title: String
    
    init(_ title: String, cancelLabel: String = "Cancel", cancelAction: Action? = nil, doneLabel: String = "Done", doneAction: Action? = nil) {
        self.title = title
        self.cancelLabel = cancelLabel
        self.cancelAction = cancelAction
        self.doneLabel = doneLabel
        self.doneAction = doneAction
    }
    
    var body: some View {
        HStack(alignment: .center) {
            HStack {
                if cancelAction != nil {
                Button(action: cancelAction!) { Text(cancelLabel) }
                    .accessibility(identifier: "cancel")
                }
                Spacer()
            }
            Text(title)
                .font(.headline)
                .fixedSize()
                .accessibility(identifier: "formHeader")
            HStack {
                Spacer()
                Button(action: doneAction!) { Text(doneLabel) }
                    .accessibility(identifier: "done")
            }
        }.padding([.leading, .trailing, .top], 20)
    }
}
