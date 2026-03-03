// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(macOS)

import SwiftUI
import Core

public struct StatusMenuLabel: View {
  @Environment(StatusService.self) var status

  public init() {
  }

  public var body: some View {
    Image(systemName: statusSymbolName())
  }
  
  func statusSymbolName() -> String {
    if status.running > 0 || status.queued > 0 {
      return "arrow.triangle.2.circlepath"
    }

    if status.failing > 0 {
      return "xmark.circle"
    }

    return "checkmark.circle"
  }

}


public struct StatusMenuContent: View {
  @Environment(LaunchService.self) var launchService
  @Environment(MetadataService.self) var metadataService
  @Environment(Engine.self) var engine
  @Environment(StatusService.self) var status

  public init() {
  }
  
  public var body: some View {
    ForEach(status.sortedRepos) { repo in
      Button {
        launchService.openWorkflow(for: repo)
      } label: {
        Label(repo.name, systemImage: repo.state.symbolName)
      }
    }

    Divider()

    Button("Show \(appName)") {
      if let window = NSApp.windows.first {
        window.makeKeyAndOrderFront(nil)
      }
      NSApp.activate(ignoringOtherApps: true)
    }
    
    SettingsLink {
      Text("Settings…")
    }
    
    Button("Add Local Repos", action: engine.addLocalRepos)
      .keyboardShortcut("o", modifiers: .command)
    
    Button("Quit \(appName)") {
      NSApp.terminate(nil)
    }
    .keyboardShortcut("q", modifiers: .command)
  }
  
  var appName: String {
    metadataService.info.name
  }
}

private extension Repo.State {
  var symbolName: String {
    switch self {
      case .unknown: return "questionmark.circle"
      case .dormant: return "moon.zzz"
      case .passing: return "checkmark.circle"
      case .failing: return "xmark.circle"
      case .partiallyFailing: return "xmark.circle"
      case .queued: return "clock.arrow.circlepath"
      case .running: return "arrow.triangle.2.circlepath"
    }
  }
}

#endif
