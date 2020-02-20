// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct RepoEditView: View {
    #if os(tvOS)
    let style = DefaultTextFieldStyle()
    #else
    let style = RoundedBorderTextFieldStyle()
    #endif
    
    @Binding var repo: Repo
    @State var editableRepo: Repo = Repo()
    @State var branches: String = ""
    
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

                HStack {
                    Text("Branches")
                        .font(.callout)
                        .bold()
                    
                    TextField("branches", text: $branches)
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
            self.load()
        }
        .onDisappear() {
            self.save()
        }
        .configureNavigation(title: repo.name)
    }
    
    var hasChanged: Bool {
        return repo != editableRepo
    }
    
    func load() {
        self.branches = self.repo.branches.joined(separator: ", ")
        self.editableRepo = self.repo
    }
    
    func save() {
        self.editableRepo.branches = self.branches.split(separator: ",").map({ String($0.trimmingCharacters(in: .whitespaces)) })
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
