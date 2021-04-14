// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct LinkButton: View {
    @EnvironmentObject var viewState: ViewState
    
    let url: URL

    var body: some View {
        Button(action: handleLink) {
            Image(systemName: viewState.linkIcon)
                .foregroundColor(.gray)
        }
    }
    
    func handleLink() {
        viewState.host.open(url: url)
    }
}
