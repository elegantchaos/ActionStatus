// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/10/2025.
//  Copyright © 2025 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Icons
import SwiftUI

#if os(watchOS)
  public struct CommandShortcut {
    public init(_ key: CommandKey, modifiers: CommandModifiers = []) {
    }
  }

  public struct CommandModifiers: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
      self.rawValue = rawValue
    }

    public static let command = CommandModifiers(rawValue: 1 << 0)
    public static let option = CommandModifiers(rawValue: 1 << 1)
    public static let shift = CommandModifiers(rawValue: 1 << 2)
    public static let control = CommandModifiers(rawValue: 1 << 3)
  }

  public typealias CommandKey = String

#else

  public typealias CommandShortcut = KeyboardShortcut
  public typealias CommandModifiers = EventModifiers
  public typealias CommandKey = KeyEquivalent
#endif


/// A command that can be surfaced by a UI.
@MainActor
public protocol CommandWithUI: Command {
  /// The user-visible name of the command.
  var name: String { get }

  /// The icon for the command.
  var icon: Icon { get }

  /// An optional help string for the command.
  /// Can be shown in a tooltip or help menu.
  var help: String? { get }

  /// An optional confirmation dialog to show before performing the command.
  var confirmation: CommandConfirmation? { get }

  /// The bundle to use for localization and other resources.
  var bundle: Bundle { get }

  /// The keyboard shortcut for the command, if any.
  var shortcut: CommandShortcut? { get }
}

@MainActor
public extension CommandWithUI {

  /// By default, the name is a localized String using the command ID as the key.
  var name: String { String(localized: String.LocalizationValue(id), bundle: bundle) }

  /// By default, no confirmation is required.
  var confirmation: CommandConfirmation? { nil }

  /// By default, the help string is looked up using the command ID.
  var help: String? { String(localized: String.LocalizationValue(id + ".help"), bundle: bundle) }

  /// By default, use the main bundle for localization and resources.
  var bundle: Bundle { .main }

  /// By default, no shortcut is provided.
  var shortcut: CommandShortcut? { nil }
}
