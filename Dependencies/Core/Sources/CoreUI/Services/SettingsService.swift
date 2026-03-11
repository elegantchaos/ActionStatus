// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Combine
import Core
import Foundation
import Keychain
import Logger
import SwiftUI

public let settingsChannel = Channel("Settings")

/// Service that manages user-configurable settings.
@Observable
@MainActor
public class SettingsService {
  /// Whether editing UI is currently enabled.
  public var isEditing = false

  /// Creates a settings service.
  public init() {
  }

  /// Reads the stored GitHub token.
  func readToken() -> String {
    let user = UserDefaults.standard.value(forKey: .githubUser)
    let server = UserDefaults.standard.value(forKey: .githubServer)
    let token = try? Keychain.default.password(for: user, on: server)
    return token ?? ""
  }

  /// Toggles editing mode and returns the new state.
  public func toggleEditing() -> Bool {
    withAnimation {
      isEditing = !isEditing
    }
    return isEditing
  }

  /// Persists a new GitHub token.
  func writeToken(_ token: String) {
    do {
      let user = UserDefaults.standard.value(forKey: .githubUser)
      let server = UserDefaults.standard.value(forKey: .githubServer)
      try Keychain.default.update(password: token, for: user, on: server)
    } catch {
      print("Failed to save token \(error)")
    }
  }
}

public extension UserDefaults {
  /// Returns the configured repository navigation mode for the specified click trigger.
  func repoNavigationMode(for trigger: NavigationTrigger) -> NavigationMode {
    NavigationMode.resolve(
      for: trigger,
      primaryClick: value(forKey: .navigationMode),
      commandClick: value(forKey: .commandNavigationMode),
      optionClick: value(forKey: .optionNavigationMode)
    )
  }
  
  /// Calls the supplied action when defaults change, after a debounce delay.
  func onChanged(delay: TimeInterval = 1.0, _ action: @escaping () -> Void) -> AnyCancellable {
    NotificationCenter.default
      .publisher(for: UserDefaults.didChangeNotification, object: self)
      .debounce(for: .seconds(delay), scheduler: RunLoop.main)
      .sink { _ in action() }
  }
}
