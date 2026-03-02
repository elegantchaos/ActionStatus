// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/02/26.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(macOS)
  import Core
  import CoreUI
  import SwiftUI

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

  private struct StatusMenuContent: View {
    let application: MacEngine
    let status: RepoState

    var body: some View {
      ForEach(status.sortedRepos) { repo in
        Button {
          application.openWorkflow(for: repo)
        } label: {
          Label(repo.name, systemImage: repo.state.symbolName)
        }
      }

      Divider()

      Button("Show \(application.info.name)") {
        application.showWindow(nil)
      }
      SettingsLink {
        Text("Settings…")
      }
      Button("Add Local Repos", action: application.addLocalRepos)
        .keyboardShortcut("o", modifiers: .command)
      Button("Quit \(application.info.name)") {
        application.handleQuit(nil)
      }
      .keyboardShortcut("q", modifiers: .command)
    }
  }

  private struct StatusMenuLabel: View {
    let application: MacEngine
    let status: RepoState

    var body: some View {
      let _ = status.combinedState
      Image(systemName: application.statusSymbolName())
    }
  }

  @main
  struct MacApp: App {
    @NSApplicationDelegateAdaptor(MacEngine.self) private var application
    @Environment(SettingsService.self) private var settingsService
    @AppStorage(.showInMenuKey) private var showInMenu = true

    var body: some Scene {
      WindowGroup {
        application.applyEnvironment(to: ContentView())
      }
      Settings {
        application.applyEnvironment(to: AppSettingsView())
      }
      .defaultSize(width: 720, height: 620)
      .windowResizability(.automatic)
      .commands {
        CommandGroup(after: .newItem) {
          Button("Add Local Repos", action: application.addLocalRepos)
            .keyboardShortcut("o", modifiers: .command)
        }
      }

      MenuBarExtra(isInserted: $showInMenu) {
        StatusMenuContent(application: application, status: application.status)
      } label: {
        StatusMenuLabel(application: application, status: application.status)
      }
    }
  }
#endif
