// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Runtime
import SwiftUI

public struct EditView: View {
  let repo: Repo?

  @Environment(\.dismiss) private var dismissAction
  @Environment(Model.self) var model
  @Environment(ViewContext.self) var context

  var title: String { "\(shortTitle) Repository" }
  var shortTitle: String { return repo == nil ? "Add" : "Edit" }

  @State var name = ""
  @State var owner = ""
  @State var workflows: [Repo.WorkflowSelection] = []
  @State var branches: String = ""

  public var body: some View {
    let localPath = repo?.url(forDevice: Device().identifier)?.path ?? ""

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
            LabeledContent("branches") {
              TextField("branch1, branch2, …", text: $branches)
                .modifier(BranchListStyle())
                .modifier(ClearButton(text: $branches))
            }
          } header: {
            Text("Details")
          } footer: {
            Text("Enter the name and owner of the repository. Select which workflows to monitor when they have been discovered, and optionally enter specific branches to test.")
          }

          Section {
            if workflows.isEmpty {
              Text("No workflows have been discovered yet for this repository.")
                .foregroundStyle(.secondary)
            } else {
              ForEach($workflows) { $workflow in
                Toggle(isOn: $workflow.enabled) {
                  VStack(alignment: .leading, spacing: 2) {
                    Text(workflow.name)
                    Text(workflow.path)
                      .font(.caption)
                      .foregroundStyle(.secondary)
                  }
                }
              }
            }
          } header: {
            Text("Workflows")
          } footer: {
            Text("Newly discovered workflows are enabled by default.")
          }

          Section {
            LabeledContent("repo") {
              HStack(alignment: .firstTextBaseline) {
                Text("https://github.com/\(trimmedOwner)/\(trimmedName)")
                  .lineLimit(1)
                  .truncationMode(.middle)
                Spacer()
                Button(action: { context.host.open(url: updatedRepo.githubURL(for: .repo)) }) {
                  Image(systemName: context.linkIcon)
                    .foregroundColor(.gray)
                }
              }
            }

            LabeledContent("status") {
              HStack(alignment: .firstTextBaseline) {
                Text("https://github.com/\(trimmedOwner)/\(trimmedName)/actions")
                  .lineLimit(1)
                  .truncationMode(.middle)
                Spacer()
                Button(action: { context.host.open(url: updatedRepo.githubURL(for: .workflow)) }) {
                  Image(systemName: context.linkIcon)
                    .foregroundColor(.gray)
                }
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
      workflows = repo.workflows.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })
      branches = repo.branches.joined(separator: ", ")
    }
  }

  func save() {
    model.update(repo: updatedRepo)
  }

  var updatedRepo: Repo {
    var updated =
      self.repo
      ?? Repo()
    updated.name = trimmedName
    updated.owner = trimmedOwner
    updated.workflows = workflows
    updated.branches = trimmedBranches
    updated.state = Repo.State.unknown
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
