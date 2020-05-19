// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ActionStatusCore
import SwiftUI
import SwiftUIExtensions
import Introspect

struct CenteringColumnPreferenceKey: PreferenceKey {
    typealias Value = [CenteringColumnPreference]

    static var defaultValue: [CenteringColumnPreference] = []

    static func reduce(value: inout [CenteringColumnPreference], nextValue: () -> [CenteringColumnPreference]) {
        value.append(contentsOf: nextValue())
    }
}

struct CenteringColumnPreference: Equatable {
    let width: CGFloat
}

struct CenteringView: View {
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.clear)
                .preference(
                    key: CenteringColumnPreferenceKey.self,
                    value: [CenteringColumnPreference(width: geometry.frame(in: CoordinateSpace.global).width)]
                )
        }
    }
}

struct Label: View {
    let name: String
    let width: Binding<CGFloat?>
    var body: some View {
        Text(name)
            .font(.callout)
            .bold()
            .frame(width: width.wrappedValue, alignment: .leading)
            .lineLimit(1)
            .background(CenteringView())
    }
    
    init(_ name: String, width: Binding<CGFloat?>) {
        self.name = name
        self.width = width
    }
}

struct EditView: View {
    #if os(tvOS)
    static let fieldStyle = DefaultTextFieldStyle()
    #else
    static let fieldStyle = RoundedBorderTextFieldStyle()
    #endif

    let repoID: UUID?
    
    @State private var width: CGFloat? = nil

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
        VStack() {
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
                Section(header: Text("Settings")) {
                    HStack {
                        Label("Name", width: $width)
                        TextField("github repo name", text: $name)
                            .nameOrgStyle()
                            .modifier(ClearButton(text: $name))
                        //                        .introspectTextField { textField in
                        //                            textField.becomeFirstResponder()
                        //                        }
                    }
                    
                    HStack {
                        Label("Owner", width: $width)
                        TextField("github user or organisation", text: $owner)
                            .nameOrgStyle()
                            .modifier(ClearButton(text: $owner))
                    }
                    
                    HStack {
                        Label("Workflow", width: $width)
                        TextField("Tests.yml", text: $workflow)
                            .nameOrgStyle()
                            .modifier(ClearButton(text: $workflow))
                    }
                    
                    HStack {
                        Label("Branches", width: $width)
                        TextField("comma-separated list of branches (leave empty for default branch)", text: $branches)
                            .branchListStyle()
                            .modifier(ClearButton(text: $branches))
                    }
                    
                }
                
                Section(header: Text("Details")) {
                    HStack {
                        Label("File", width: $width)
                        Text("\(trimmedWorkflow).yml")
                    }
                    
                    HStack {
                        Label("Repo", width: $width)
                        Text("https://github.com/\(trimmedOwner)/\(trimmedName)")

                        Spacer()
                        
                        Button(action: openRepo) {
                            SystemImage("arrowshape.turn.up.right.circle")
                        }
                    }
                    
                    HStack{
                        Label("Status", width: $width)
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
        .onPreferenceChange(CenteringColumnPreferenceKey.self) { preferences in
            for p in preferences {
                let oldWidth = self.width ?? CGFloat.zero
                if p.width > oldWidth {
                    self.width = p.width
                }
            }
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
