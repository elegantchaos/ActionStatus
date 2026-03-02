// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/10/2025.
//  Copyright © 2025 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import SwiftUI

/// Represents an icon backed by an SF Symbol system image.
nonisolated public struct Icon: Sendable {
  /// The SF Symbols image to use.
  public let systemImage: String
  
  /// Construct an icon from the given system image name.
  public init(_ value: String) {
    systemImage = value
  }
}

/// Alias to disambiguate usage of Icon as a key in situations where
/// it is also used as a generic parameter.
public typealias IconKey = Icon

//extension IconKey: ExpressibleByStringLiteral {
//  public init(stringLiteral value: StringLiteralType) {
//    key = value
//  }
//}

public extension Image {
  init(icon key: Icon) {
    self.init(systemName: key.systemImage)
  }
}

#if canImport(UIKit)
public extension UIImage {
  convenience init?(systemName key: Icon) {
    self.init(systemName: key.systemImage)
  }
}
#endif

public extension Label where Title == Text, Icon == Image {
  init(_ titleKey: LocalizedStringResource, icon key: IconKey) {
    self.init(titleKey, systemImage: key.systemImage)
  }

  init(_ titleKey: LocalizedStringKey, icon key: IconKey) {
    self.init(titleKey, systemImage: key.systemImage)
  }
  
  init(_ title: String, icon key: IconKey) {
    self.init(title, systemImage: key.systemImage)
  }
}

