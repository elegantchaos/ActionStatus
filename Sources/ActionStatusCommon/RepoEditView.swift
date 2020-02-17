// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct RepoEditView: View {
    #if canImport(UIKit)
    let style = RoundedBorderTextFieldStyle()
    #else
    let style = DefaultTextFieldStyle()
    #endif
    
    @Binding var repo: Repo
    @State var editableRepo: Repo = Repo()
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Name")
                        .font(.callout)
                        .bold()
                    TextField("name", text: $editableRepo.name)
                        .textFieldStyle(style)
                }
                
                HStack {
                    Text("Owner")
                        .font(.callout)
                        .bold()
                    
                    TextField("owner", text: $editableRepo.owner)
                        .textFieldStyle(style)
                }
                
                HStack {
                    Text("Workflow")
                        .font(.callout)
                        .bold()
                    
                    TextField("workflow", text: $editableRepo.workflow)
                        .textFieldStyle(style)
                }
            }
            
            Section {
                HStack {
                    Text("Repo")
                        .font(.callout)
                        .bold()
                    
                    Text("https://github.com/\(editableRepo.owner)/\(editableRepo.name)")
                }
                
                HStack {
                    Text("File")
                        .font(.callout)
                        .bold()
                    
                    Text("\(editableRepo.workflow).yml")
                }
                
                HStack{
                    Text("Status")
                        .font(.callout)
                        .bold()
                    
                    Text("https://github.com/elegantchaos/Logger/actions?query=workflow%3A\(editableRepo.workflow)")
                }
            }
        }
        .onAppear() {
            AppDelegate.shared.repos.cancelRefresh()
            self.editableRepo = self.repo
        }
        .onDisappear() {
            self.save()
        }
        .configureNavigation(title: repo.name)
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

fileprivate extension View {
    #if canImport(UIKit)
    func configureNavigation(title: String) -> some View {
        return navigationBarTitle(title)
            .navigationBarHidden(false)
    }
    #else
    func configureNavigation(title: String) -> some View {
        return self
    }
    #endif
}
