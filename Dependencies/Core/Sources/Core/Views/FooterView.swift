// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SheetController
import SwiftUI
import SwiftUIExtensions

public struct FooterView: View {
  @EnvironmentObject var updater: Updater
  @EnvironmentObject var status: RepoState
  @EnvironmentObject var sheetController: SheetController

  let namespace: Namespace.ID

  #if os(tvOS)
    let focus: FocusState<Focus?>.Binding
    public init(namespace: Namespace.ID, focus: FocusState<Focus?>.Binding) {
      self.namespace = namespace
      self.focus = focus
    }
  #endif

  public var body: some View {
    VStack(spacing: 10) {
      if !updater.status.isEmpty {
        Text(updater.status)
          .statusStyle()
      } else {
        HStack(spacing: 8) {
          #if os(tvOS)
            Spacer()
              .frame(width: 32)
            Spacer()
          #endif

          Text("Monitoring \(status.sortedRepos.count) repos.")
          if status.failing > 0 {
            HStack(spacing: 4) {
              StatusIcon("StatusFailing")
              Text("\(status.failing) failing.")
            }
          }

          if status.queued > 0 {
            HStack(spacing: 4) {
              StatusIcon("StatusQueued")
              Text("\(status.queued) queued.")
            }
          }

          if status.running > 0 {
            HStack(spacing: 4) {
              StatusIcon("StatusRunning")
              Text("\(status.running) running.")
            }
          }

          if status.unreachable > 0 {
            HStack(spacing: 4) {
              StatusIcon("StatusUnknown")
              Text("\(status.unreachable) unreachable.")
            }
          }

          #if os(tvOS)
            Spacer()
            PreferencesButton()
              .prefersDefaultFocus(in: namespace)
              .focused(focus, equals: .prefs)
              .buttonStyle(FadingFocusButtonStyle())
              .frame(width: 32)
          #endif

        }
        .statusStyle()
      }
    }
    .padding()
    .frame(maxWidth: .infinity)
  }

  var hasUpdate: Bool {
    return updater.hasUpdate
  }

  var showProgress: Bool {
    return (updater.progress > 0.0) && (updater.progress < 1.0)
  }

}
