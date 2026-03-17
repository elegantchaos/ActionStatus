// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Application
import Foundation
import Keychain
import Logger
import Observation

public let settingsChannel = Channel("Settings")

/// Service that manages user-configurable settings.
@Observable
@MainActor
public final class SettingsService {
  @ObservationIgnored private let defaults: UserDefaults
  @ObservationIgnored private var defaultsObserver: NotificationToken?

  /// Whether editing UI is currently enabled.
  public var isEditing = false

  /// Whether the app should show a menu-bar entry.
  public private(set) var showInMenu: Bool

  /// Whether the app should appear in the Dock.
  public private(set) var showInDock: Bool

  /// Current refresh interval preference.
  public private(set) var refreshInterval: RefreshRate

  /// Current repo sort preference.
  public private(set) var sortMode: SortMode

  /// Current display size preference.
  public private(set) var displaySize: DisplaySize

  /// Current GitHub login.
  public private(set) var githubUser: String

  /// Current GitHub API server.
  public private(set) var githubServer: String

  /// Preferred primary navigation mode.
  public private(set) var navigationMode: NavigationMode

  /// Preferred secondary navigation mode.
  public private(set) var secondaryNavigationMode: NavigationMode

  /// Preferred tertiary navigation mode.
  public private(set) var tertiaryNavigationMode: NavigationMode

  /// Creates a settings service.
  public init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
    self.showInMenu = defaults.actionStatusValue(for: .showInMenu)
    self.showInDock = defaults.actionStatusValue(for: .showInDock)
    self.refreshInterval = defaults.actionStatusValue(for: .refreshInterval)
    self.sortMode = defaults.actionStatusValue(for: .sortMode)
    self.displaySize = defaults.actionStatusValue(for: .displaySize)
    self.githubUser = defaults.actionStatusValue(for: .githubUser)
    self.githubServer = defaults.actionStatusValue(for: .githubServer)
    self.navigationMode = defaults.actionStatusValue(for: .navigationMode)
    self.secondaryNavigationMode = defaults.actionStatusValue(for: .secondaryNavigationMode)
    self.tertiaryNavigationMode = defaults.actionStatusValue(for: .tertiaryNavigationMode)
    self.defaultsObserver = defaults.onActionStatusSettingsChanged { [weak self] in
      self?.reloadStoredValues()
    }
  }

  /// Toggles editing mode and returns the new state.
  public func toggleEditing() -> Bool {
    isEditing.toggle()
    return isEditing
  }

  /// Returns the configured navigation mode for the supplied trigger.
  public func repoNavigationMode(for trigger: CommandTrigger) -> NavigationMode {
    switch trigger {
      case .primary:
        navigationMode
      case .secondary:
        secondaryNavigationMode
      case .tertiary:
        tertiaryNavigationMode
    }
  }

  /// Reads the stored GitHub token.
  public func readToken() -> String {
    let token = try? Keychain.default.password(for: githubUser, on: githubServer)
    return token ?? ""
  }

  /// Persists a new GitHub token.
  public func writeToken(_ token: String) {
    do {
      try Keychain.default.update(password: token, for: githubUser, on: githubServer)
    } catch {
      settingsChannel.log("Failed to save token: \(error)")
    }
  }

  private func reloadStoredValues() {
    showInMenu = defaults.actionStatusValue(for: .showInMenu)
    showInDock = defaults.actionStatusValue(for: .showInDock)
    refreshInterval = defaults.actionStatusValue(for: .refreshInterval)
    sortMode = defaults.actionStatusValue(for: .sortMode)
    displaySize = defaults.actionStatusValue(for: .displaySize)
    githubUser = defaults.actionStatusValue(for: .githubUser)
    githubServer = defaults.actionStatusValue(for: .githubServer)
    navigationMode = defaults.actionStatusValue(for: .navigationMode)
    secondaryNavigationMode = defaults.actionStatusValue(for: .secondaryNavigationMode)
    tertiaryNavigationMode = defaults.actionStatusValue(for: .tertiaryNavigationMode)
  }
}
