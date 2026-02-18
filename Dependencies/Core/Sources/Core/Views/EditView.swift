// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Hardware
import SwiftUI
import SwiftUIExtensions

public struct EditView: View {
  static let fieldStyle = Shim.RoundedBorderTextFieldStyle()

  let repo: Repo?

  @Environment(\.presentationMode) var presentation
  @EnvironmentObject var model: Model
  @EnvironmentObject var context: ViewContext

  var title: String { "\(shortTitle) Repository" }
  var shortTitle: String { return repo == nil ? "Add" : "Edit" }

  @State var name = ""
  @State var owner = ""
  @State var workflow = ""
  @State var branches: String = ""

  public var body: some View {
    let localPath = repo?.url(forDevice: Device.main.identifier)?.path ?? ""
    let detailStyle = NameOrgStyle()

    return
      SheetView(title, shortTitle: shortTitle, cancelAction: dismiss, doneAction: done) {
        Form {
          FormSection(
            header: "Details",
            footer: "Enter the name and owner of the repository, and the name of the workflow file to test. Enter a list of specific branches to test, or leave blank to just test the default branch."
          ) {
            FormFieldRow(label: "name", placeholder: "github repo name", variable: $name, style: detailStyle, clearButton: true)
            FormFieldRow(label: "owner", placeholder: "github user or organisation", variable: $owner, style: detailStyle, clearButton: true)
            FormFieldRow(label: "workflow", placeholder: "Tests.yml", variable: $workflow, style: detailStyle, clearButton: true)
            FormFieldRow(label: "branches", placeholder: "branch1, branch2, …", variable: $branches, style: BranchListStyle(), clearButton: true)
          }

          FormSection(
            header: "Locations",
            footer: "Corresponding locations on Github."
          ) {
            FormRow(label: "repo") {
              HStack(alignment: .firstTextBaseline) {
                Text("https://github.com/\(trimmedOwner)/\(trimmedName)")
                Spacer()
                LinkButton(url: updatedRepo.githubURL(for: .repo))
              }
            }

            FormRow(label: "status") {
              HStack(alignment: .firstTextBaseline) {
                Text("https://github.com/\(trimmedOwner)/\(trimmedName)/actions?query=workflow%3A\(trimmedWorkflow)")
                Spacer()
                LinkButton(url: updatedRepo.githubURL(for: .workflow))
              }
            }

            if !localPath.isEmpty {
              FormRow(label: "local") {
                Text(localPath)
              }
            }
          }
        }
      }
      .environmentObject(context.formStyle)
      .onAppear {
        context.host.pauseRefresh()
        self.load()
      }
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
    context.host.resumeRefresh()
    presentation.wrappedValue.dismiss()
  }

  func done() {
    save()
    dismiss()
  }

  func load() {
    if let repo = repo {
      name = repo.name
      owner = repo.owner
      workflow = repo.workflow
      branches = repo.branches.joined(separator: ", ")
    }
  }

  func save() {
    model.update(repo: updatedRepo)
  }

  var updatedRepo: Repo {
    var updated = self.repo ?? Repo(model: model)
    updated.name = trimmedName
    updated.owner = trimmedOwner
    updated.workflow = trimmedWorkflow
    updated.branches = trimmedBranches
    updated.state = .unknown
    return updated
  }
}


struct RepoEditView_Previews: PreviewProvider {
  static var previews: some View {
    let context = PreviewContext()
    return context.inject(into: EditView(repo: context.testRepo))
  }
}

struct NameOrgStyle: ViewModifier {
  func body(content: Content) -> some View {
    content
      .keyboardType(.namePhonePad)
      .textContentType(.name)
      .disableAutocorrection(true)
      .autocapitalization(.none)
      .modifier(DefaultFormFieldStyle())
  }
}

struct BranchListStyle: ViewModifier {
  func body(content: Content) -> some View {
    content
      .keyboardType(.alphabet)
      .disableAutocorrection(true)
      .autocapitalization(.none)
      .modifier(DefaultFormFieldStyle())
  }
}
