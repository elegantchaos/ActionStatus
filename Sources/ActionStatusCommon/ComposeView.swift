// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 19/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct ComposeView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Text("Composing View")
            Button(action: { self.isPresented = false }) {
                Text("Dismiss")
            }
        }
        
    }
}


struct ComposeView_Previews: PreviewProvider {
    static var previews: some View {
        ComposeView(isPresented: .constant(false))
    }
}
