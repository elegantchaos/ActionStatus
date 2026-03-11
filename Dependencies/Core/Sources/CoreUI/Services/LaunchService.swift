// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Core

@Observable
@MainActor public class LaunchService {
  public func openWorkflow(for repo: Repo) {
    open(url: repo.githubURL(for: .workflow))
  }
}

#if canImport(UIKit)
  import UIKit
  extension LaunchService {
    func open(url: URL) {
      UIApplication.shared.open(url)
    }
    open func reveal(url: URL) {
      UIApplication.shared.open(url)
    }
  }
#elseif canImport(AppKit)
  import AppKit
  extension LaunchService {
    func open(url: URL) {
      NSWorkspace.shared.open(url)
    }
    func reveal(url: URL) {
      NSWorkspace.shared.activateFileViewerSelecting([url])
    }
  }
#else
extension LaunchService {
  func open(url: URL) {
  }
  open func reveal(url: URL) {
  }
}
#endif
