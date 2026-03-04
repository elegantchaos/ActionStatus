// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/10/2025.
//  Copyright © 2025 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI

/// UI Support
@MainActor
public extension CommandCentre {
  /// Determine whether the given command should be disabled in the UI.
  // TODO: track commands whilst they are running, and disable their buttons appropriately
  func shouldDisable<C: CommandWithUI>(_ command: C) -> Bool where C.Centre == Self {
    switch availability(command) {
      case .disabled, .running, .runningSilently: return true
      default: return false
    }
  }

  /// Return a button for the given command, or nothing if the command is not available.
  @ViewBuilder func button<C: CommandWithUI>(_ command: C, role: ButtonRole? = nil) -> some View where C.Centre == Self {
    let availability = availability(command)
    if availability != .hidden {
      Button(role: role, action: { performWithoutWaiting(command) }) {
        Label(command.name, icon: command.icon)
      }
      .disabled(shouldDisable(command))
      #if !os(watchOS)
        .keyboardShortcut(command.shortcut)
      #endif
      .help(command.help ?? "")
    }
  }

  /// Return a button for the given command with custom content, or nothing if the command is not available.
  @ViewBuilder func button<C: CommandWithUI, Content: View>(_ command: C, role: ButtonRole? = nil, content: () -> Content) -> some View where C.Centre == Self {
    let availability = availability(command)
    if availability != .hidden {
      Button(role: role, action: { performWithoutWaiting(command) }) {
        content()
      }
      .disabled(shouldDisable(command))
      #if !os(watchOS)
        .keyboardShortcut(command.shortcut)
      #endif
      .help(command.help ?? "")
    }
  }

  /// Return a button for the given command with custom content, or nothing if the command is not available.
  @ViewBuilder func button<C: CommandWithUI, Content: View>(_ command: C, role: ButtonRole? = nil, content: (C) -> Content) -> some View where C.Centre == Self {
    let availability = availability(command)
    if availability != .hidden {
      Button(role: role, action: { performWithoutWaiting(command) }) {
        content(command)
      }
      .disabled(shouldDisable(command))
      #if !os(watchOS)
        .keyboardShortcut(command.shortcut)
      #endif
      .help(command.help ?? "")
    }
  }

  /// Return a button for the given command that shows a confirmation dialog before performing the command, or nothing if the command is not available.
  @ViewBuilder func confirmableButton<C: CommandWithUI>(_ command: C) -> some View where C.Centre == Self {
    let availability = availability(command)
    if availability != .hidden {
      ConfirmableCommandButton(command: command, commander: self)
        .disabled(shouldDisable(command))
        #if !os(watchOS)
          .keyboardShortcut(command.shortcut)
        #endif
        .help(command.help ?? "")
    }
  }

  /// Return a toolbar item for the given command, or nothing if the command is not available.
  @ToolbarContentBuilder func toolbarItem<C: CommandWithUI>(_ command: C, placement: ToolbarItemPlacement = .automatic) -> some ToolbarContent where C.Centre == Self {
    if availability(command) != .hidden {
      ToolbarItem(placement: placement) {
        button(command)
      }
    }
  }

  /// Return a toolbar item for the given command that shows a confirmation dialog before performing the command, or nothing if the command is not available.
  @ToolbarContentBuilder func confirmableToolbarItem<C: CommandWithUI>(_ command: C, placement: ToolbarItemPlacement = .automatic) -> some ToolbarContent where C.Centre == Self {
    if availability(command) != .hidden {
      ToolbarItem(placement: placement) {
        confirmableButton(command)
      }
    }
  }

  /// Return a toolbar item group for the given command, or nothing if the command is not available.
  @ToolbarContentBuilder func toolbarItemGroup<C: CommandWithUI>(_ command: C, placement: ToolbarItemPlacement = .automatic) -> some ToolbarContent where C.Centre == Self {
    if availability(command) != .hidden {
      ToolbarItemGroup(placement: placement) {
        button(command)
      }
    }
  }

  //  func menu<each C: Command>(_ command: repeat each C) -> some View where repeat (each C).Centre == Self {
  //    return Menu {
  //      repeat button(each command)
  //    } label: {
  //      Label("action.more", systemImage: "ellipsis.circle")
  //    }
  //  }

}
