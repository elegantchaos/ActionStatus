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
      } else {
        ZStack(alignment: .top) {
          RepoGridView(namespace: namespace, focus: $focus)
            .opacity(settingsService.isEditing ? 0 : 1)
            .allowsHitTesting(!settingsService.isEditing)
            .accessibilityHidden(settingsService.isEditing)

          RepoListView(namespace: namespace, focus: $focus)
            .opacity(settingsService.isEditing ? 1 : 0)
            .allowsHitTesting(settingsService.isEditing)
            .accessibilityHidden(!settingsService.isEditing)
        }
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
