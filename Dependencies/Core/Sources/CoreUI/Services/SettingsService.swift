// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Combine
import Foundation
import Keychain
import Logger

public let settingsChannel = Channel("Settings")

@Observable
@MainActor
public class SettingsService {
  var isEditing = false

  func readToken() -> String {
    let user = UserDefaults.standard.value(forKey: .githubUser)
    let server = UserDefaults.standard.value(forKey: .githubServer)
    let token = try? Keychain.default.password(for: user, on: server)
    return token ?? ""
  }

  public func toggleEditing() -> Bool {
    isEditing = !isEditing
    return isEditing
  }

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
  func onChanged(delay: TimeInterval = 1.0, _ action: @escaping () -> Void) -> AnyCancellable {
    NotificationCenter.default
      .publisher(for: UserDefaults.didChangeNotification, object: self)
      .debounce(for: .seconds(delay), scheduler: RunLoop.main)
      .sink { _ in action() }
  }
}
