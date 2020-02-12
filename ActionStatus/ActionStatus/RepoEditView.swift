// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct RepoEditView: View {
    @State var repo: Repo
    
    var body: some View {
        HStack {
            TextField("name", text: $repo.name)
            TextField("owner", text: $repo.owner)
            TextField("workflow", text: $repo.workflow)
        }
     }
    
}

struct RepoEditView_Previews: PreviewProvider {
    static var previews: some View {
        RepoEditView(repo: Repo("Test", owner: "Owner", workflow: "Workflow", testState: .passing))
    }
}
