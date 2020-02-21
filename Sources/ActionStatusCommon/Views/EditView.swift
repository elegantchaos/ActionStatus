// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct EditView: View {
    #if os(tvOS)
    let style = DefaultTextFieldStyle()
    #else
    let style = RoundedBorderTextFieldStyle()
    #endif
    
    @Binding var repo: Repo
    @State var name = ""
    @State var owner = ""
    @State var workflow = ""
    @State var branches: String = ""
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Name")
                        .font(.callout)
                        .bold()
                    TextField("github repo name", text: $name)
                        .textFieldStyle(style)
                }
                
                HStack {
                    Text("Owner")
                        .font(.callout)
                        .bold()
                    
                    TextField("github user or organisation", text: $owner)
                        .textFieldStyle(style)
                }
                
                HStack {
                    Text("Workflow")
                        .font(.callout)
                        .bold()
                    
                    TextField("Tests.yml", text: $workflow)
                        .textFieldStyle(style)
                }

                HStack {
                    Text("Branches")
                        .font(.callout)
                        .bold()
                    
                    TextField("branches to check (uses default branch if empty)", text: $branches)
                        .textFieldStyle(style)
                    
                }

            }
            
            Section {
                HStack {
                    Text("Repo")
                        .font(.callout)
                        .bold()
                    
                    Text("https://github.com/\(trimmedOwner)/\(trimmedName)")
                }
                
                HStack {
                    Text("File")
                        .font(.callout)
                        .bold()
                    
                    Text("\(trimmedWorkflow).yml")
                }
                
                HStack{
                    Text("Status")
                        .font(.callout)
                        .bold()
                    
                    Text("https://github.com/elegantchaos/Logger/actions?query=workflow%3A\(trimmedWorkflow)")
                }
            }
        }
        .onAppear() {
            AppDelegate.shared.model.cancelRefresh()
            self.load()
        }
        .onDisappear() {
            self.save()
        }
        .configureNavigation(title: "\(trimmedOwner)/\(trimmedName)")
    }
    
    var trimmedWorkflow: String {
        var stripped = workflow.trimmingCharacters(in: .whitespaces)
        if let range = stripped.range(of: ".yml") {
            stripped.removeSubrange(range)
        }
        return stripped
    }
    
    var trimmedName: String {
        return name.trimmingCharacters(in: .whitespaces)
    }
    
    var trimmedOwner: String {
        return owner.trimmingCharacters(in: .whitespaces)
    }
    
    var trimmedBranches: [String] {
        return branches.split(separator: ",").map({ String($0.trimmingCharacters(in: .whitespaces)) })
    }
    
    func load() {
        name = repo.name
        owner = repo.owner
        workflow = repo.workflow
        branches = repo.branches.joined(separator: ", ")
    }
    
    func save() {
        repo.name = trimmedName
        repo.owner = trimmedOwner
        repo.workflow = trimmedWorkflow
        repo.branches = trimmedBranches
        AppDelegate.shared.stateWasEdited()
    }
}

struct RepoEditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(repo: AppDelegate.shared.$testRepos.items[0])
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
