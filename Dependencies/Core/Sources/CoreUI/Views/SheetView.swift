// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Sheet container providing a consistent toolbar with cancel and done buttons.
///
/// Wraps its `content` in a `NavigationStack` and places toolbar items using
/// standard placement constants. On tvOS the `shortTitle` is shown in the
/// principal toolbar position to fit the narrower layout.
public struct SheetView<Content>: View where Content: View {
  /// Closure type for cancel and done actions.
  typealias Action = () -> Void

  /// Full title shown in the toolbar on non-tvOS platforms.
  let title: String
  /// Abbreviated title used on tvOS.
  let shortTitle: String
  /// Optional cancel action; when `nil` the cancel button is hidden.
  let cancelAction: Action?
  /// Label for the cancel button.
  let cancelLabel: String
  /// Action invoked when the user taps Done.
  let doneAction: Action
  /// Label for the done button.
  let doneLabel: String
  /// Content of the sheet.
  let content: () -> Content

  init(
    _ title: String,
    shortTitle: String,
    cancelAction: Action? = nil,
    cancelLabel: String = "Cancel",
    doneAction: @escaping Action,
    doneLabel: String = "Done",
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.title = title
    self.shortTitle = shortTitle
    self.cancelAction = cancelAction
    self.cancelLabel = cancelLabel
    self.doneAction = doneAction
    self.doneLabel = doneLabel
    self.content = content
  }

  public var body: some View {
    NavigationStack {
      content()
        #if os(iOS)
          .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
          ToolbarItem(placement: .principal) {
            Text(displayTitle)
              .accessibility(identifier: "formHeader")
          }

          ToolbarItem(placement: .cancellationAction) {
            if let action = cancelAction {
              CancelButton(label: cancelLabel, action: action)
            }
          }

          ToolbarItem(placement: .confirmationAction) {
            Button(action: doneAction) { Text(doneLabel) }
              .accessibility(identifier: "done")
              #if !os(tvOS)
                .keyboardShortcut(.defaultAction)
              #endif
          }
        }
    }
  }

  /// The title displayed in the toolbar; abbreviated on tvOS.
  private var displayTitle: String {
    #if os(tvOS)
      shortTitle
    #else
      title
    #endif
  }

  /// Toolbar button that triggers the cancel action.
  private struct CancelButton: View {
    let label: String
    let action: Action

    var body: some View {
      Button(action: action) { Text(label) }
        .accessibility(identifier: "cancel")
        #if !os(tvOS)
          .keyboardShortcut(.cancelAction)
        #endif
    }
  }
}
