// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct FormHeaderView: View {
    let cancelLabel: String
    let cancelAction: () -> Void
    let doneLabel: String
    let doneAction: () -> Void
    let title: String
    
    init(_ title: String, cancelLabel: String = "Cancel", cancelAction: @escaping () -> Void, doneLabel: String = "Done", doneAction: @escaping () -> Void) {
        self.title = title
        self.cancelLabel = cancelLabel
        self.cancelAction = cancelAction
        self.doneLabel = doneLabel
        self.doneAction = doneAction
    }
    
    var body: some View {
        HStack(alignment: .center) {
            HStack {
                Button(action: cancelAction) { Text(cancelLabel) }
                    .accessibility(identifier: "cancel")
                Spacer()
            }
            Text(title)
                .font(.headline)
                .fixedSize()
                .accessibility(identifier: "formHeader")
            HStack {
                Spacer()
                Button(action: doneAction) { Text(doneLabel) }
                    .accessibility(identifier: "done")
            }
        }.padding([.leading, .trailing, .top], 20)
    }
}
