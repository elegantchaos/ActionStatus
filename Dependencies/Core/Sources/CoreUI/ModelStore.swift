// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Foundation

/// Protocol for something that can save and load the model.
public protocol ModelStore {
  @discardableResult func synchronize() -> Bool
  var index: [String] { get set }
  func repo(forKey: String) -> Repo?
  func store(_ repo: Repo, forKey: String) -> Bool
  func removeObject(forKey: String)
}
