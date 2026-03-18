// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(macOS)

  import Core
  import Runtime
  import SwiftUI

  /// Menu bar status icon for ActionStatus.
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

  /// Menu bar status menu content for ActionStatus.
  public struct StatusMenuContent: View {
    @Environment(ActionStatusCommander.self) var commander
    @Environment(LaunchService.self) var launchService
    @Environment(StatusService.self) var status

    /// Runtime metadata. Injectable for test purposes.
    let runtime: Runtime

    public init(runtime: Runtime = .shared) {
      self.runtime = runtime
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

      Button("Show \(runtime.appName)") {
        if let window = NSApp.windows.first {
          window.makeKeyAndOrderFront(nil)
        }
        NSApp.activate(ignoringOtherApps: true)
      }

      SettingsLink {
        Text("Settings…")
      }

      commander.importer(AddLocalReposCommand())

      Button("Quit \(runtime.appName)") {
        NSApp.terminate(nil)
      }
      .keyboardShortcut("q", modifiers: .command)
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
