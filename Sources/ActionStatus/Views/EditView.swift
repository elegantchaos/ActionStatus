// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ActionStatusCore
import SwiftUI
import SwiftUIExtensions
import Introspect

struct EditView: View {
    #if os(tvOS)
    static let fieldStyle = DefaultTextFieldStyle()
    #else
    static let fieldStyle = RoundedBorderTextFieldStyle()
    #endif

    let repoID: UUID?
    
    @State private var labelWidth: CGFloat = 0

    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var model: Model
    @EnvironmentObject var viewState: ViewState
    
    var title: String { return "\(trimmedName)" }
    var repo: Repo? {
        guard let repoID = repoID, let repo = model.repo(withIdentifier: repoID) else { return nil }
        return repo
    }
    
    @State var name = Repo.defaultName
    @State var owner = Repo.defaultOwner
    @State var workflow = Repo.defaultWorkflow
    @State var branches: String = Repo.defaultBranches.joined(separator: ", ")
    
    var body: some View {
        VStack() {
            FormHeaderView(title, cancelAction: dismiss, doneAction: done)

            Form {
                Section(
                    header: Text("Repository Details").font(viewState.formHeaderFont),
                    footer: Text("Enter the name and owner of the repository, and the name of the workflow file to test. Enter a list of specific branches to test, or leave blank to just test the default branch.")
                ) {
                    HStack {
                        Label("name", width: $labelWidth)
                        TextField("github repo name", text: $name)
                            .nameOrgStyle()
                            .modifier(ClearButton(text: $name))
                        //                        .introspectTextField { textField in
                        //                            textField.becomeFirstResponder()
                        //                        }
                    }
                    
                    HStack {
                        Label("owner", width: $labelWidth)
                        TextField("github user or organisation", text: $owner)
                            .nameOrgStyle()
                            .modifier(ClearButton(text: $owner))
                    }
                    
                    HStack {
                        Label("workflow", width: $labelWidth)
                        TextField("Tests.yml", text: $workflow)
                            .nameOrgStyle()
                            .modifier(ClearButton(text: $workflow))
                    }
                    
                    HStack {
                        Label("branches", width: $labelWidth)
                        TextField("comma-separated list of branches (leave empty for default branch)", text: $branches)
                            .branchListStyle()
                            .modifier(ClearButton(text: $branches))
                    }
                    
                }.padding([.bottom])
                
                Section(
                    header: Text("Github Links").font(viewState.formHeaderFont),
                    footer: Text("Corresponding locations on Github.").multilineTextAlignment(.center)
                ) {
                    HStack {
                        Label("repo", width: $labelWidth)
                        Text("https://github.com/\(trimmedOwner)/\(trimmedName)").bold()

                        Spacer()
                        
                        Button(action: openRepo) {
                            SystemImage("arrowshape.turn.up.right.circle")
                        }
                    }
                    
                    HStack{
                        Label("status", width: $labelWidth)
                        Text("https://github.com/\(trimmedOwner)/\(trimmedName)/actions?query=workflow%3A\(trimmedWorkflow)").bold()

                        Spacer()
                        
                        Button(action: openWorkflow) {
                            SystemImage("arrowshape.turn.up.right.circle")
                        }
                    }

                    if self.repo != nil {
                        HStack{
                            Label("local", width: $labelWidth)
                            Text(String(describing: self.repo?.paths))
                        }
                    }

                }
            }
        }
        .onAppear() {
            Application.shared.model.cancelRefresh()
            self.load()
        }
        .alignLabels(width: $labelWidth)
        
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
        if stripped.isEmpty {
            stripped = "Tests"
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
        return context.inject(into: EditView(repoID: context.testRepo.id))
    }
}

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
