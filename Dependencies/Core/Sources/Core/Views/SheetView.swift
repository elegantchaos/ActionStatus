// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import SwiftUIExtensions

public struct SheetView<Content>: View where Content: View {
  typealias Action = () -> Void

  init(_ title: String, shortTitle: String, cancelAction: Action? = nil, cancelLabel: String = "Cancel", doneAction: @escaping Action, doneLabel: String = "Done", @ViewBuilder content: @escaping () -> Content) {
    self.title = title
    self.shortTitle = shortTitle
    self.cancelAction = cancelAction
    self.cancelLabel = cancelLabel
    self.doneAction = doneAction
    self.doneLabel = doneLabel
    self.content = content
  }

  let title: String
  let shortTitle: String
  let cancelAction: Action?
  let cancelLabel: String
  let doneAction: Action
  let doneLabel: String
  let content: () -> Content

  public var body: some View {
    NavigationView {
      AlignedLabelContainer {
        content()
      }
      #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
      #endif
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(displayTitle)
            .accessibility(identifier: "formHeader")
        }

        ToolbarItem(placement: cancelPlacement) {
          if let action = cancelAction {
            CancelButton(label: cancelLabel, action: action)
          }
        }

        ToolbarItem(placement: confirmationPlacement) {
          Button(action: doneAction) { Text(doneLabel) }
            .accessibility(identifier: "done")
            #if !os(tvOS)
              .keyboardShortcut(.defaultAction)
            #endif
        }
      }
    }
  }

  let cancelPlacement = ToolbarItemPlacement.cancellationAction
  let confirmationPlacement = ToolbarItemPlacement.confirmationAction
  var displayTitle: String {
    #if os(tvOS)
      shortTitle
    #else
      title
    #endif
  }

  struct CancelButton: View {
    let label: String
    let action: Action!

    var body: some View {
      Button(action: action!) { Text(label) }
        .accessibility(identifier: "cancel")
        #if !os(tvOS)
          .keyboardShortcut(.cancelAction)
        #endif
    }
  }

}
