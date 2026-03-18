import Core
import CoreUI
import Previews
import Runtime
import SwiftUI

private struct RepoCellPreviewHost: View {
  @Namespace private var namespace
  @FocusState private var focus: Focus?

  let repo: Repo

  var body: some View {
    let context = RepoContainerContext(namespace: namespace, runtime: .shared, focus: $focus)
    RepoCellView(repo: repo, context: context, selectable: false)
      .frame(width: 320)
      .padding()
  }
}

private struct RepoListPreviewHost: View {
  @Namespace private var namespace
  @FocusState private var focus: Focus?

  var body: some View {
    RepoListView(context: RepoContainerContext(namespace: namespace, runtime: .shared, focus: $focus))
  }
}

private struct RepoGridPreviewHost: View {
  @Namespace private var namespace
  @FocusState private var focus: Focus?

  var body: some View {
    RepoGridView(context: RepoContainerContext(namespace: namespace, runtime: .shared, focus: $focus))
      .frame(minWidth: 700, minHeight: 420)
  }
}

#Preview("Repo Cell Passing") {
  PreviewRoot(ActionStatusPreviews.repoCellPassing) { fixture in
    RepoCellPreviewHost(repo: fixture.primaryRepo)
  }
}

#Preview("Repo Cell Failing") {
  PreviewRoot(ActionStatusPreviews.repoCellFailing) { fixture in
    RepoCellPreviewHost(repo: fixture.primaryRepo)
  }
}

#Preview("Repo List") {
  PreviewRoot(ActionStatusPreviews.editing) { _ in
    RepoListPreviewHost()
  }
}

#Preview("Repo Grid") {
  PreviewRoot(ActionStatusPreviews.content) { _ in
    RepoGridPreviewHost()
  }
}

#Preview("Repos Filled") {
  PreviewRoot(ActionStatusPreviews.content) { _ in
    ReposView()
      .frame(minWidth: 720, minHeight: 460)
  }
}

#Preview("Repos Empty") {
  PreviewRoot(ActionStatusPreviews.empty) { _ in
    ReposView()
      .frame(minWidth: 720, minHeight: 460)
  }
}

#Preview("Content View") {
  PreviewRoot(ActionStatusPreviews.content) { _ in
    ContentView()
      .frame(minWidth: 720, minHeight: 460)
  }
}

#Preview("Edit Existing Repo") {
  PreviewRoot(ActionStatusPreviews.editExisting) { fixture in
    EditView(repo: fixture.primaryRepo)
      .frame(minWidth: 600, minHeight: 640)
  }
}

#if os(macOS)
  #Preview("Status Menu Label") {
    PreviewRoot(ActionStatusPreviews.statusMenu) { _ in
      StatusMenuLabel()
        .padding()
    }
  }

  #Preview("Status Menu Content") {
    PreviewRoot(ActionStatusPreviews.statusMenu) { _ in
      VStack(alignment: .leading, spacing: 0) {
        StatusMenuContent()
      }
      .frame(width: 280)
      .padding()
    }
  }
#endif
