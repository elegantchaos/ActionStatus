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

struct ClearButton: ViewModifier
{
    @Binding var text: String

    public func body(content: Content) -> some View
    {
        ZStack(alignment: .trailing)
        {
            content

            if !text.isEmpty
            {
                Button(action:
                {
                    self.text = ""
                })
                {
                    Image(systemName: "multiply.circle.fill")
                        .foregroundColor(Color(UIColor.opaqueSeparator))
                }
                .padding(.trailing, 8)
            }
        }
    }
}

struct EditView: View {
    #if os(tvOS)
    static let fieldStyle = DefaultTextFieldStyle()
    #else
    static let fieldStyle = RoundedBorderTextFieldStyle()
    #endif

    let repoID: UUID
    
    @EnvironmentObject var model: Model
    
    var repo: Repo {
        model.repo(withIdentifier: repoID)!
    }
    
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
                    
                    Button(action: { Application.shared.openGithub(with: self.repo, at: .repo) }) {
                        SystemImage("arrowshape.turn.up.right")
                    }
                }
                
                HStack{
                    Text("Workflow URL")
                        .font(.callout)
                        .bold()
                    
                    Text("https://github.com/\(trimmedOwner)/\(trimmedName)/actions?query=workflow%3A\(trimmedWorkflow)")
                    
                    Spacer()
                    
                    Button(action: { Application.shared.openGithub(with: self.repo, at: .workflow) }) {
                        SystemImage("arrowshape.turn.up.right")
                    }
                }
            }
        }
        .onAppear() {
            Application.shared.model.cancelRefresh()
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
        Application.shared.stateWasEdited()
    }
}

struct RepoEditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(repoID: Application.shared.testRepos[0].id)
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


struct CustomTextField: UIViewRepresentable {

    class Coordinator: NSObject, UITextFieldDelegate {

        @Binding var text: String
        var didBecomeFirstResponder = false

        init(text: Binding<String>) {
            _text = text
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }

    }

    init(_ prototype: String, text: Binding<String>, isFirstResponder: Bool) {
        self.prototype = prototype
        self._text = text
        self.isFirstResponder = isFirstResponder
    }
    
    let prototype: String
    @Binding var text: String
    var isFirstResponder: Bool = false

    func makeUIView(context: UIViewRepresentableContext<CustomTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        return textField
    }

    func makeCoordinator() -> CustomTextField.Coordinator {
        return Coordinator(text: $text)
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomTextField>) {
        uiView.text = text
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}
