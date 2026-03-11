// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import Foundation
import Observation

/// Service responsible for opening remote URLs and revealing local files.
@Observable
@MainActor
open class LaunchService {
  /// Creates a launch service.
  public init() {
  }

  /// Opens the workflow page for the supplied repository.
  public func openWorkflow(for repo: Repo) {
    open(url: repo.githubURL(for: .workflow))
  }

  /// Opens the supplied URL.
  open func open(url: URL) {
    #if canImport(UIKit)
      UIApplication.shared.open(url)
    #elseif canImport(AppKit)
      NSWorkspace.shared.open(url)
    #endif
  }

  /// Reveals the supplied local URL.
  open func reveal(url: URL) {
    #if canImport(UIKit)
      UIApplication.shared.open(url)
    #elseif canImport(AppKit)
      NSWorkspace.shared.activateFileViewerSelecting([url])
    #endif
  }
}

#if canImport(UIKit)
  import UIKit
#elseif canImport(AppKit)
  import AppKit
#endif
