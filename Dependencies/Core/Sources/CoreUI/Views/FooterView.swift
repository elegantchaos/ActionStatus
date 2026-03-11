// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

public struct FooterView: View {
  @Environment(StatusService.self) var status

  let namespace: Namespace.ID
  let focus: FocusState<Focus?>.Binding

  #if os(tvOS)
    public init(namespace: Namespace.ID, focus: FocusState<Focus?>.Binding) {
      self.namespace = namespace
      self.focus = focus
    }
  #endif

  public var body: some View {
    VStack(spacing: 10) {
      #if os(iOS)
        VStack(spacing: 4) {
          Text("Monitoring \(status.sortedRepos.count) repos.")
            .frame(maxWidth: .infinity, alignment: .center)

          HStack(spacing: 8) {
            if status.failing > 0 {
              HStack(spacing: 3) {
                Image(systemName: "xmark.circle")
                  .foregroundStyle(.red)
                Text("\(status.failing) failing")
              }
            }

            if status.queued > 0 {
              HStack(spacing: 3) {
                Image(systemName: "clock.arrow.circlepath")
                  .foregroundStyle(.secondary)
                Text("\(status.queued) queued")
              }
            }

            if status.running > 0 {
              HStack(spacing: 3) {
                Image(systemName: "arrow.triangle.2.circlepath")
                  .foregroundStyle(.secondary)
                Text("\(status.running) running")
              }
            }

            if status.unreachable > 0 {
              HStack(spacing: 3) {
                Image(systemName: "questionmark.circle")
                Text("\(status.unreachable) unreachable")
              }
            }
          }
          .lineLimit(1)
          .minimumScaleFactor(0.85)
        }
        .font(.footnote)
      #else
        HStack(spacing: 8) {
          #if os(tvOS)
            Spacer()
              .frame(width: 32)
            Spacer()
          #endif

          Text("Monitoring \(status.sortedRepos.count) repos.")
          if status.failing > 0 {
            HStack(spacing: 4) {
              Image(systemName: "xmark.circle")
                .foregroundStyle(.red)
              Text("\(status.failing) failing.")
            }
          }

          if status.queued > 0 {
            HStack(spacing: 4) {
              Image(systemName: "clock.arrow.circlepath")
                .foregroundStyle(.secondary)
              Text("\(status.queued) queued.")
            }
          }

          if status.running > 0 {
            HStack(spacing: 4) {
              Image(systemName: "arrow.triangle.2.circlepath")
                .foregroundStyle(.secondary)
              Text("\(status.running) running.")
            }
          }

          if status.unreachable > 0 {
            HStack(spacing: 4) {
              Image(systemName: "questionmark.circle")
              Text("\(status.unreachable) unreachable.")
            }
          }

          #if os(tvOS)
            Spacer()
            Button(action: { context.presentedSheet = .preferences }) {
              Image(systemName: context.preferencesIcon)
            }
            .accessibility(identifier: "preferencesButton")
            .prefersDefaultFocus(in: namespace)
            .focused(focus, equals: .prefs)
            .buttonStyle(FadingFocusButtonStyle())
            .frame(width: 32)
          #endif

        }
        .statusStyle()
      #endif
    }
    .padding()
    .frame(maxWidth: .infinity)
  }
}
