// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Core
import Previews
import Runtime
import SwiftUI

/// Form used to add and edit monitored repositories.
public struct EditView: View {
  @Environment(LaunchService.self) private var launchService
  @Environment(\.dismiss) private var dismissAction
  @Environment(ModelService.self) var modelService
  @Environment(RefreshService.self) var refreshService
  @Environment(ActionStatusCommander.self) var commander

  @State var name = ""
  @State var owner = ""
  @State var workflows: [Repo.WorkflowSelection] = []
  @State var branches: String = ""

  /// The repository being edited; `nil` when adding a new repository.
  let repo: Repo?

  var title: String { "\(shortTitle) Repository" }
  var shortTitle: String { repo == nil ? "Add" : "Edit" }

  /// Runtime metadata. Injectable for test purposes.
  let runtime: Runtime

  /// Creates an edit view for the supplied repository.
  public init(repo: Repo? = nil, runtime: Runtime = .shared) {
    self.repo = repo
    self.runtime = runtime
  }

  public var body: some View {
    let localPath = repo?.localURL(forDevice: runtime.deviceIdentifier)?.path ?? ""

    return SheetView(title, shortTitle: shortTitle, cancelAction: dismiss, doneAction: done) {
      Form {
        EditDetailsSectionView(name: $name, owner: $owner, branches: $branches)

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
            .font(.footnote)
            .foregroundStyle(.secondary)
        }

        Section {
          LabeledContent("repo", icon: .showRepo) {
            commander.button(ShowRepoCommand(repo: updatedRepo)) {
              Text(updatedRepo.githubURL(for: .repo).absoluteString)
            }
          }

          LabeledContent("status", icon: .showWorkflow) {
            commander.button(ShowWorkflowCommand(repo: updatedRepo)) {
              Text(updatedRepo.githubURL(for: .workflow).absoluteString)
            }
          }

          if !localPath.isEmpty {
            LabeledContent("local", icon: .revealLocalRepo) {
              commander.button(RevealLocalCommand(repo: updatedRepo)) {
                Text(localPath)
              }
            }
          }
        } header: {
          Text("Locations")
        } footer: {
          Text("Corresponding locations on Github.")
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
      }
      .labelStyle(.iconOnly)
    }
    .formStyle(.grouped)
    .textFieldStyle(.plain)
    .onAppear {
      refreshService.pauseRefresh()
      load()
    }
  }

  /// Name with leading/trailing whitespace removed.
  var trimmedName: String {
    name.trimmingCharacters(in: .whitespaces)
  }

  /// Owner with leading/trailing whitespace removed.
  var trimmedOwner: String {
    owner.trimmingCharacters(in: .whitespaces)
  }

  /// Branch list parsed from the comma-separated text field.
  var trimmedBranches: [String] {
    branches.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
  }

  /// Resumes refresh and dismisses the sheet.
  func dismiss() {
    refreshService.resumeRefresh()
    dismissAction()
  }

  /// Saves the edited repo then dismisses the sheet.
  func done() {
    save()
    dismiss()
  }

  /// Populates local state from the stored repo, or leaves defaults for a new repo.
  func load() {
    if let repo {
      name = repo.name
      owner = repo.owner
      workflows = repo.workflows.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })
      branches = repo.branches.joined(separator: ", ")
    }
  }

  /// Writes the current form values back to the model.
  func save() {
    modelService.update(repo: updatedRepo)
  }

  /// Constructs a `Repo` value from the current form fields.
  var updatedRepo: Repo {
    var updated = repo ?? Repo()
    updated.name = trimmedName
    updated.owner = trimmedOwner
    updated.workflows = workflows
    updated.branches = trimmedBranches
    updated.state = Repo.State.unknown
    return updated
  }
}

/// Platform-appropriate text-field style for repository name and owner fields.
struct NameOrgStyle: ViewModifier {
  func body(content: Content) -> some View {
    #if os(macOS)
      content
        .textFieldStyle(.roundedBorder)
        .multilineTextAlignment(.leading)
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

/// Platform-appropriate text-field style for the branch list field.
struct BranchListStyle: ViewModifier {
  func body(content: Content) -> some View {
    #if os(macOS)
      content
        .multilineTextAlignment(.leading)
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


struct EditDetailsSectionView: View {
  @Binding var name: String
  @Binding var owner: String
  @Binding var branches: String

  var body: some View {
    Section {

      LabeledContent("name", icon: .name) {
        TextField("name", text: $name, prompt: Text("github repo"))
          .multilineTextAlignment(.leading)
          .modifier(ClearButton(text: $name))
          .labelsHidden()
      }

      LabeledContent("owner", icon: .owner) {
        TextField("owner", text: $owner, prompt: Text("github owner"))
          .multilineTextAlignment(.leading)
          .modifier(ClearButton(text: $owner))
          .labelsHidden()
      }
      LabeledContent("branches", icon: .branches) {
        TextField("", text: $branches, prompt: Text("branch1, branch2, …"))
          .multilineTextAlignment(.leading)
          .modifier(BranchListStyle())
          .modifier(ClearButton(text: $branches))
      }
    } header: {
      Text("Details")
    } footer: {
      Text("Enter the name and owner of the repository. Select which workflows to monitor when they have been discovered, and optionally enter specific branches to test.")
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
    .modifier(NameOrgStyle())
  }
}

#Preview("Edit Repo") {
  PreviewRoot(ActionStatusPreviews.editExisting) { fixture in
    EditView(repo: fixture.primaryRepo)
      .frame(minWidth: 600, minHeight: 640)
  }
}

#Preview("iOS") {
  PreviewRoot(ActionStatusPreviews.editExisting) { fixture in
    EditView(repo: fixture.primaryRepo)
  }
}

#Preview("Details") {
  @Previewable @State var name = "name"
  @Previewable @State var owner = "owner"
  @Previewable @State var branches: String = "branch1, branch2"

  PreviewRoot(ActionStatusPreviews.editExisting) { fixture in
    Form {
      EditDetailsSectionView(name: $name, owner: $owner, branches: $branches)
    }
    .labelStyle(.iconOnly)
    .formStyle(.grouped)
  }

}
