// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct RepoEditView: View {
    let style = DefaultTextFieldStyle()
    @Binding var repo: Repo
    @State var editableRepo: Repo = Repo()
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Repo Name")
                        .font(.callout)
                        .bold()
                    TextField("name", text: $editableRepo.name)
                        .textFieldStyle(style)
                }
                
                HStack {
                    Text("Repo Owner")
                        .font(.callout)
                        .bold()
                    
                    TextField("owner", text: $editableRepo.owner)
                        .textFieldStyle(style)
                }
                
                HStack {
                    Text("Workflow File Name")
                        .font(.callout)
                        .bold()
                    
                    TextField("workflow", text: $editableRepo.workflow)
                        .textFieldStyle(style)
                }
            }
            
            Section {
                HStack {
                    Text("Github Repo")
                    Text("https://github.com/\(editableRepo.owner)/\(editableRepo.name)")
                }
            }
        }
        .onAppear() {
            self.editableRepo = self.repo
        }
        .onDisappear() {
            self.save()
        }
        .navigationBarTitle(repo.name)
        .navigationBarHidden(false)
    }
    
    var hasChanged: Bool {
        return repo != editableRepo
    }
    
    func save() {
        self.repo = self.editableRepo
        AppDelegate.shared.saveState()
        AppDelegate.shared.repos.refresh()
    }
}

struct RepoEditView_Previews: PreviewProvider {
    static var previews: some View {
        RepoEditView(repo: AppDelegate.shared.$testRepos.items[0])
    }
}
