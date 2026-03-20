// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Core
import Icons
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
  @State var showBranches = false
  @State var branches: String = ""

  /// The repository being edited.
  let repo: Repo

  let adding: Bool

  /// Runtime metadata. Injectable for test purposes.
  let runtime: Runtime

  /// Creates an edit view for the supplied repository.
  public init(repo: Repo, adding: Bool, runtime: Runtime = .shared) {
    self.repo = repo
    self.adding = adding
    self.runtime = runtime
  }

  /// Title to use for the sheet.
  var title: String { "\(shortTitle) Repository" }

  /// Short title to use for the sheet.
  var shortTitle: String { adding ? "Add" : "Edit" }


  public var body: some View {

    return SheetView(title, shortTitle: shortTitle, cancelAction: dismiss, doneAction: done) {
      Form {
        EditDetailsSectionView(
          name: $name,
          owner: $owner,
          showBranches: $showBranches,
          branches: $branches
        )

        EditWorkflowsSectionView(
          workflows: $workflows
        )

        EditLocationsSectionView(
          repo: updatedRepo,
          localPath: localPath
        )
      }
    }
    .formStyle(.grouped)
    .onAppear {
      refreshService.pauseRefresh()
      load()
    }
  }

  /// Local path to the repository, if available.
  var localPath: URL? {
    repo.localURL(forDevice: runtime.deviceIdentifier)
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
    name = repo.name
    owner = repo.owner
    workflows = repo.workflows.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })
    branches = repo.branches.joined(separator: ", ")
  }

  /// Writes the current form values back to the model.
  func save() {
    modelService.update(repo: updatedRepo)
  }

  /// Constructs a `Repo` value from the current form fields.
  var updatedRepo: Repo {
    var updated = repo
    updated.name = trimmedName
    updated.owner = trimmedOwner
    updated.workflows = workflows
    updated.branches = trimmedBranches
    updated.state = Repo.State.unknown
    return updated
  }
}


struct EditDetailsSectionView: View {
  @Binding var name: String
  @Binding var owner: String
  @Binding var showBranches: Bool
  @Binding var branches: String

  var body: some View {
    EditSectionView("Details", footer: "Enter the name and owner of the repository.\nOptionally enter specific branches to test.") {
      LabeledField($name, label: "Name", prompt: "github repo", icon: .name)
      LabeledField($owner, label: "Owner", prompt: "github owner", icon: .owner)
      Toggle(isOn: $showBranches) {
        Label("Filter By Branch", icon: .filterBranches)
      }
      if showBranches {
        LabeledField($branches, label: "Match branches", prompt: "branch1, branch2, …", icon: .branches)
      }
    }
  }
}

struct EditWorkflowsSectionView: View {
  @Binding var workflows: [Repo.WorkflowSelection]

  var body: some View {
    EditSectionView("Workflows", footer: "Select which workflows to monitor when they have been discovered.\nNewly discovered workflows are enabled by default.") {
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
    }
  }
}

struct EditLocationsSectionView: View {
  @Environment(ActionStatusCommander.self) var commander

  /// The repository being edited; `nil` when adding a new repository.
  let repo: Repo

  /// Local path to the repository, if available.
  let localPath: URL?

  var body: some View {
    EditSectionView("Locations", footer: "Corresponding locations on Github and/or the local device.") {
      LabeledLink("Github - Main Page", icon: .showRepo, command: ShowRepoCommand(repo: repo), url: repo.githubURL(for: .repo))
      LabeledLink("Github - Actions", icon: .showWorkflow, command: ShowWorkflowCommand(repo: repo), url: repo.githubURL(for: .workflow))
      if let localPath {
        LabeledLink("Local", icon: .revealLocalRepo, command: RevealLocalCommand(url: localPath), url: localPath)
      }
    }
  }
}

#Preview("Editing") {
  PreviewRoot(ActionStatusPreviews.editExisting) { fixture in
    EditView(repo: fixture.primaryRepo, adding: false)
  }
}

#Preview("Adding") {
  PreviewRoot(ActionStatusPreviews.editExisting) { fixture in
    EditView(repo: fixture.primaryRepo, adding: true)
  }
}

#Preview("Details") {
  @Previewable @State var name = "name"
  @Previewable @State var owner = "owner"
  @Previewable @State var branches: String = "branch1, branch2"
  @Previewable @State var showBranches: Bool = false

  PreviewRoot(ActionStatusPreviews.editExisting) { fixture in
    Form {
      EditDetailsSectionView(name: $name, owner: $owner, showBranches: $showBranches, branches: $branches)
    }
    .formStyle(.grouped)
  }
}

#Preview("Workflows") {
  @Previewable @State var workflows: [Repo.WorkflowSelection] = []
  
  PreviewRoot(ActionStatusPreviews.editExisting) { fixture in
    Form {
      EditWorkflowsSectionView(workflows: $workflows)
    }
    .formStyle(.grouped)
  }
}

#Preview("Locations") {
  PreviewRoot(ActionStatusPreviews.editExisting) { fixture in
    Form {
      EditLocationsSectionView(repo: fixture.primaryRepo, localPath: .testLocalURL)
    }
    .formStyle(.grouped)
  }
}
