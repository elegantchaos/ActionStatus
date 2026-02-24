// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Hardware
import SwiftUI

public struct EditView: View {
  let repo: Repo?

  @Environment(\.dismiss) private var dismissAction
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

    return
      SheetView(title, shortTitle: shortTitle, cancelAction: dismiss, doneAction: done) {
        Form {
          Section {
            LabeledContent("name") {
              TextField("github repo name", text: $name)
                .modifier(NameOrgStyle())
                .modifier(ClearButton(text: $name))
            }
            LabeledContent("owner") {
              TextField("github user or organisation", text: $owner)
                .modifier(NameOrgStyle())
                .modifier(ClearButton(text: $owner))
            }
            LabeledContent("workflow") {
              TextField("Tests.yml", text: $workflow)
                .modifier(NameOrgStyle())
                .modifier(ClearButton(text: $workflow))
            }
            LabeledContent("branches") {
              TextField("branch1, branch2, …", text: $branches)
                .modifier(BranchListStyle())
                .modifier(ClearButton(text: $branches))
            }
          } header: {
            Text("Details")
          } footer: {
            Text("Enter the name and owner of the repository, and the name of the workflow file to test. Enter a list of specific branches to test, or leave blank to just test the default branch.")
          }

          Section {
            LabeledContent("repo") {
              HStack(alignment: .firstTextBaseline) {
                Text("https://github.com/\(trimmedOwner)/\(trimmedName)")
                  .lineLimit(1)
                  .truncationMode(.middle)
                Spacer()
                LinkButton(url: updatedRepo.githubURL(for: .repo))
              }
            }

            LabeledContent("status") {
              HStack(alignment: .firstTextBaseline) {
                Text("https://github.com/\(trimmedOwner)/\(trimmedName)/actions?query=workflow%3A\(trimmedWorkflow)")
                  .lineLimit(1)
                  .truncationMode(.middle)
                Spacer()
                LinkButton(url: updatedRepo.githubURL(for: .workflow))
              }
            }

            if !localPath.isEmpty {
              LabeledContent("local") {
                Text(localPath)
                  .lineLimit(1)
                  .truncationMode(.middle)
              }
            }
          } header: {
            Text("Locations")
          } footer: {
            Text("Corresponding locations on Github.")
          }
        }
      }
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
    dismissAction()
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
    #if os(macOS)
      content
        .textFieldStyle(.roundedBorder)
    #else
      content
        .keyboardType(.namePhonePad)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        #if os(tvOS)
          .textFieldStyle(.automatic)
        #else
          .textFieldStyle(.roundedBorder)
        #endif
    #endif
  }
}

struct BranchListStyle: ViewModifier {
  func body(content: Content) -> some View {
    #if os(macOS)
      content
        .textFieldStyle(.roundedBorder)
    #else
      content
        .keyboardType(.alphabet)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        #if os(tvOS)
          .textFieldStyle(.automatic)
        #else
          .textFieldStyle(.roundedBorder)
        #endif
    #endif
  }
}
