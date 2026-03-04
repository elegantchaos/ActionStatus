// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/10/2025.
//  Copyright © 2025 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Information needed to display a confirmation dialog for a command.
public struct CommandConfirmation {
  public let title: String
  public let cancel: String
  public let message: String
  public let confirm: String
  
  public init(title: String, cancel: String, message: String, confirm: String) {
    self.title = title
    self.cancel = cancel
    self.message = message
    self.confirm = confirm
  }
  
  public init(titleKey: LocalizedStringResource, cancelKey: LocalizedStringResource, messageKey: LocalizedStringResource, confirmKey: LocalizedStringResource) {
    self.init(title: String(localized: titleKey), cancel: String(localized: cancelKey), message: String(localized: messageKey), confirm: String(localized: confirmKey))
  }
}
