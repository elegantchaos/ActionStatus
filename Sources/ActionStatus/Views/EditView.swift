// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ActionStatusCore
import SwiftUI
import SwiftUIExtensions
import Introspect

extension View {
    func nameOrgStyle() -> some View {

        return textFieldStyle(EditView.fieldStyle)
            .keyboardType(.namePhonePad)
            .textContentType(.name)
            .disableAutocorrection(true)
            .autocapitalization(.none)
    }

    func branchListStyle() -> some View {
        return textFieldStyle(EditView.fieldStyle)
            .keyboardType(.alphabet)
            .disableAutocorrection(true)
            .autocapitalization(.none)
    }

}


struct EditView: View {
    #if os(tvOS)
    static let fieldStyle = DefaultTextFieldStyle()
    #else
    static let fieldStyle = RoundedBorderTextFieldStyle()
    #endif

    let repoID: UUID?
    
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var model: Model
    
    var title: String { return "\(trimmedName)" }
    var repo: Repo? {
        guard let repoID = repoID, let repo = model.repo(withIdentifier: repoID) else { return nil }
        return repo
    }
    
    @State var name = ""
    @State var owner = ""
    @State var workflow = ""
    @State var branches: String = ""
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                HStack {
                    Button(action: dismiss) { Text("Cancel") }
                    Spacer()
                }
                Text(title).font(.headline).fixedSize()
                HStack {
                    Spacer()
                    Button(action: done) { Text("Done") }
                }
            }.padding([.leading, .trailing, .top], 20)

            Form {
                Section {
                    HStack {
                        Text("Name")
                            .font(.callout)
                            .bold()
                        TextField("github repo name", text: $name)
                            .nameOrgStyle()
                            .modifier(ClearButton(text: $name))
                        //                        .introspectTextField { textField in
                        //                            textField.becomeFirstResponder()
                        //                        }
                    }
                    
                    HStack {
                        Text("Owner")
                            .font(.callout)
                            .bold()
                        
                        TextField("github user or organisation", text: $owner)
                            .nameOrgStyle()
                            .modifier(ClearButton(text: $owner))
                    }
                    
                    HStack {
                        Text("Workflow")
                            .font(.callout)
                            .bold()
                        
                        TextField("Tests.yml", text: $workflow)
                            .nameOrgStyle()
                            .modifier(ClearButton(text: $workflow))
                    }
                    
                    HStack {
                        Text("Branches")
                            .font(.callout)
                            .bold()
                        
                        TextField("comma-separated list of branches (leave empty for default branch)", text: $branches)
                            .branchListStyle()
                            .modifier(ClearButton(text: $branches))
                    }
                    
                }
                
                Section {
                    HStack {
                        Text("Workflow File")
                            .font(.callout)
                            .bold()
                        
                        Text("\(trimmedWorkflow).yml")
                    }
                    
                    HStack {
                        Text("Repo URL")
                            .font(.callout)
                            .bold()
                        
                        Text("https://github.com/\(trimmedOwner)/\(trimmedName)")
                        
                        Spacer()
                        
                        Button(action: openRepo) {
                            SystemImage("arrowshape.turn.up.right.circle")
                        }
                    }
                    
                    HStack{
                        Text("Workflow URL")
                            .font(.callout)
                            .bold()
                        
                        Text("https://github.com/\(trimmedOwner)/\(trimmedName)/actions?query=workflow%3A\(trimmedWorkflow)")
                        
                        Spacer()
                        
                        Button(action: openWorkflow) {
                            SystemImage("arrowshape.turn.up.right.circle")
                        }
                    }
                }
            }
        }
        .onAppear() {
            Application.shared.model.cancelRefresh()
            self.load()
        }
    }
    
    func openRepo() {
        Application.shared.openGithub(with: update(repo: Repo()), at: .repo)
    }
    
    func openWorkflow() {
        Application.shared.openGithub(with: update(repo: Repo()), at: .workflow)
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
    
    func dismiss() {
        presentation.wrappedValue.dismiss()
    }
    
    func done() {
        save()
        dismiss()
    }
    
    func load() {
        if let repoID = repoID, let repo = model.repo(withIdentifier: repoID) {
            name = repo.name
            owner = repo.owner
            workflow = repo.workflow
            branches = repo.branches.joined(separator: ", ")
        }
    }
    
    func save() {
        let repo = self.repo ?? Repo()
        let updated = update(repo: repo)
        model.update(repo: updated)
        Application.shared.stateWasEdited()
    }
    
    func update(repo: Repo) -> Repo {
        var updated = repo
        updated.name = trimmedName
        updated.owner = trimmedOwner
        updated.workflow = trimmedWorkflow
        updated.branches = trimmedBranches
        return updated
    }
}


struct RepoEditView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PreviewContext()
        return context.inject(into: EditView(repoID: context.repos.first!.id))
    }
}
