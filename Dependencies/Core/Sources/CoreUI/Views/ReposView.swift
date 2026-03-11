// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/05/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Combine
import SwiftUI

/// View containing all the repos, in a list or grid layout.
struct ReposView: View {
  @Namespace() var namespace
  @Environment(ModelService.self) var modelService
  @Environment(Engine.self) var engine
  @Environment(SettingsService.self) var settingsService

  @State var focusState = FadingFocusState()
  @FocusState var focus: Focus?

  var body: some View {
    VStack(alignment: .center) {
      if modelService.count == 0 {
        NoReposView()
      } else if settingsService.isEditing {
          RepoListView(namespace: namespace, focus: $focus)
      } else {
          RepoGridView(namespace: namespace, focus: $focus)
      }

      Spacer()
        FooterView(namespace: namespace, focus: $focus)
    }
    .onAppear(perform: handleAppear)
    #if os(tvOS)
      .focusScope(defaultNamespace)
      .environment(focusState)
      .onChange(of: focus) { value in
        focusState.handleFocusChanged()
      }
    #endif
  }

  func handleAppear() {
    #if os(tvOS)
      focusState.handleFocusChanged()
    #endif
  }

}

public enum Focus: Hashable, Equatable {
  case repo(UUID)
  case prefs
}
