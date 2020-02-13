// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct RepoEditView: View {
    let style = RoundedBorderTextFieldStyle()
    @Binding var repo: Repo
    @State var editableRepo: Repo = Repo()
    
    var body: some View {
        VStack {
            Text("Repo")
                .font(.callout)
                .bold()
            TextField("name", text: $editableRepo.name)
                .textFieldStyle(style)
            
            Text("Owner")
                .font(.callout)
                .bold()
            
            TextField("owner", text: $editableRepo.owner)
                .textFieldStyle(style)

            Text("Workflow")
                .font(.callout)
                .bold()
            
            TextField("workflow", text: $editableRepo.workflow)
                .textFieldStyle(style)
            
            Button(action: { self.repo = self.editableRepo }) {
                Text("Save")
            }
        }
        .padding(.horizontal)
        .onAppear() {
            self.editableRepo = self.repo
        }
    }
    
}

struct RepoEditView_Previews: PreviewProvider {
    static var previews: some View {
        RepoEditView(repo: AppDelegate.shared.$testRepos.items[0])
    }
}
