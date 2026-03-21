// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/05/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Runtime
import SwiftUI

/// View containing all monitored repositories in their chosen layout.
public struct ReposView: View {
  @Environment(ModelService.self) var modelService
  @Environment(SettingsService.self) var settingsService
  @Environment(\.authService) private var authService

  @Namespace() var namespace
  @State var focusState = FadingFocusState()
  @FocusState var focus: Focus?

  /// Runtime metadata. Injectable for testing purposes.
  let runtime: Runtime

  /// Creates a repositories container view.
  public init(runtime: Runtime = .shared) {
    self.runtime = runtime
  }

  public var body: some View {
    let context = RepoContainerContext(namespace: namespace, runtime: runtime, focus: $focus)

    return VStack(alignment: .center) {
      ZStack(alignment: .top) {
        if modelService.count == 0 {
          NoReposView()
        } else {
          ZStack(alignment: .top) {
            RepoGridView(context: context)
              .opacity(settingsService.isEditing ? 0 : 1)
              .allowsHitTesting(!settingsService.isEditing)
              .accessibilityHidden(settingsService.isEditing)

            RepoListView(context: context)
              .opacity(settingsService.isEditing ? 1 : 0)
              .allowsHitTesting(settingsService.isEditing)
              .accessibilityHidden(!settingsService.isEditing)
          }
        }

        #if !os(tvOS)
          if modelService.count > 0, let overlay = AuthMonitoringOverlayModel(state: authService.authState) {
            AuthMonitoringOverlay(model: overlay)
              .padding(.horizontal)
              .padding(.top, 12)
          }
        #endif
      }

      Spacer()
      FooterView(namespace: namespace, focus: $focus)
    }
    .onAppear(perform: handleAppear)
    #if os(tvOS)
      .focusScope(namespace)
      .environment(focusState)
      .onChange(of: focus) { _ in
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

#if !VALIDATING
  #Preview("Repos Filled", traits: .modifier(ActionStatusPreviews.Content())) {
    ReposView()
      .frame(minWidth: 720, minHeight: 460)
  }

  #Preview("Repos Signed Out", traits: .modifier(ActionStatusPreviews.AuthSignedOut())) {
    ReposView()
      .frame(minWidth: 720, minHeight: 460)
  }

  #Preview("Repos Validating", traits: .modifier(ActionStatusPreviews.AuthValidating())) {
    ReposView()
      .frame(minWidth: 720, minHeight: 460)
  }

  #Preview("Repos Auth Error", traits: .modifier(ActionStatusPreviews.AuthFailed())) {
    ReposView()
      .frame(minWidth: 720, minHeight: 460)
  }

  #Preview("Repos Empty", traits: .modifier(ActionStatusPreviews.Empty())) {
    ReposView()
      .frame(minWidth: 720, minHeight: 460)
  }
#endif
