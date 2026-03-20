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
        EditDetailsSectionView(
          name: $name,
          owner: $owner,
          showBranches: $showBranches,
          branches: $branches
        )

        EditSection("Workflows", footer: "Select which workflows to monitor when they have been discovered.\nNewly discovered workflows are enabled by default.") {
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

        EditSection("Locations", footer: "Corresponding locations on Github.") {
          LabeledContent("Github", icon: .showRepo) {
            commander.button(ShowRepoCommand(repo: updatedRepo)) {
              Text(updatedRepo.githubURL(for: .repo).absoluteString)
            }
          }
          
          LabeledContent("Action", icon: .showWorkflow) {
            commander.button(ShowWorkflowCommand(repo: updatedRepo)) {
              Text(updatedRepo.githubURL(for: .workflow).absoluteString)
            }
          }
          
          if !localPath.isEmpty {
            LabeledContent("Local", icon: .revealLocalRepo) {
              commander.button(RevealLocalCommand(repo: updatedRepo)) {
                Text(localPath)
              }
            }
            .buttonStyle(.borderless)
          }
        }
      }
    }
    .formStyle(.grouped)
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


struct EditSection<Content: View>: View {
  @ViewBuilder var content: () -> Content
  let header: LocalizedStringResource
  let footer: LocalizedStringResource

  init(_ header: LocalizedStringResource, footer: LocalizedStringResource, @ViewBuilder content: @escaping () -> Content) {
    self.content = content
    self.header = header
    self.footer = footer
  }

  var body: some View {
    Section {
      content()
    } header: {
      Text(header)
    } footer: {
      Text(footer)
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
  }
}

struct EditDetailsSectionView: View {
  @Binding var name: String
  @Binding var owner: String
  @Binding var showBranches: Bool
  @Binding var branches: String

  var body: some View {
    EditSection("Details", footer: "Enter the name and owner of the repository.\nOptionally enter specific branches to test.") {
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

struct LabeledField: View {
  @Binding var text: String
  let label: LocalizedStringResource
  let prompt: LocalizedStringResource
  let icon: Icon
  let clearable: Bool

  init(_ text: Binding<String>, label: LocalizedStringResource, prompt: LocalizedStringResource, icon: Icon, clearable: Bool = true) {
    _text = text
    self.label = label
    self.prompt = prompt
    self.icon = icon
    self.clearable = clearable
  }

  var body: some View {
    let field = TextField(label, text: $text, prompt: Text(prompt))
      .labelsHidden()
      .labeledContentStyle(LabeledFieldContentStyle())
      .multilineTextAlignment(.leading)
      #if os(macOS)
        .multilineTextAlignment(.leading)
        .textFieldStyle(.roundedBorder)
      #else
        .keyboardType(.alphabet)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
          #if os(tvOS)
            .textFieldStyle(.automatic)
          #else
            .textFieldStyle(.roundedBorder)
          #endif
      #endif

    #if os(macOS)
      return LabeledContent(label, icon: icon) {
        if clearable {
          field
            .modifier(ClearButton(text: $text))
        } else {
          field
        }
      }
    #else
      return VStack(alignment: .leading) {
        HStack {
          Image(icon: icon)
          if clearable {
            field
              .modifier(ClearButton(text: $text))
          } else {
            field
          }
        }
        //        Text(label)
        //          .font(.footnote)
        //          .foregroundStyle(.secondary)
      }
    #endif
  }
}

struct LabeledFieldContentStyle: LabeledContentStyle {
  func makeBody(configuration: Configuration) -> some View {
    HStack {
      configuration.label
      configuration.content
    }
  }
}


#Preview("Form") {
  PreviewRoot(ActionStatusPreviews.editExisting) { fixture in
    EditView(repo: fixture.primaryRepo)
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

#Preview("Section") {
  Form {
    EditSection("Header", footer: "Footer") {
      Text("Some Content Here")
    }
  }
  .formStyle(.grouped)
}

#Preview("LabelledField") {
  @Previewable @State var name = "name"

  Form {
    LabeledField($name, label: "label", prompt: "prompt", icon: .name)
  }
  //  .labelStyle(.iconOnly)
  .formStyle(.grouped)
}
