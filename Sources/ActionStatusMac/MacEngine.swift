// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/02/26.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(macOS)
  import AppKit
  import Core
  import SwiftUI

  final class MacEngine: Engine {

    override func setupDefaultSettings() {
      super.setupDefaultSettings()
      UserDefaults.standard.register(defaults: [
        .showInMenuKey: true,
        .showInDockKey: true,
      ])
    }

    override func setUp(withOptions options: LaunchOptions, completion: @escaping SetupCompletion) {
      super.setUp(withOptions: options) { [self] options in
        applyWindowSettings()

        completion(options)
      }
    }

    override func loadSettings() {
      super.loadSettings()
      applyWindowSettings()
    }

    override func reveal(url: URL) {
      NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    @objc func showPreferences() {
      sheetController.show {
        PreferencesView()
      }
      showWindow(nil)
    }

    @objc func addLocalRepos() {
      let panel = NSOpenPanel()
      panel.canChooseFiles = false
      panel.canChooseDirectories = true
      panel.allowsMultipleSelection = true
      panel.canCreateDirectories = false

      guard panel.runModal() == .OK else { return }
      model.add(fromFolders: panel.urls)
    }

    @objc func showWindow(_ sender: Any?) {
      if let window = NSApp.windows.first {
        window.makeKeyAndOrderFront(sender)
      }
      NSApp.activate(ignoringOtherApps: true)
    }

    @objc func handleQuit(_ sender: Any? = nil) {
      NSApp.terminate(sender)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
      false
    }

    private func applyWindowSettings() {
      let showInDock = UserDefaults.standard.bool(forKey: .showInDockKey)

      let activation: NSApplication.ActivationPolicy = showInDock ? .regular : .accessory
      if NSApp.activationPolicy() != activation {
        NSApp.setActivationPolicy(activation)
      }
    }

    func openWorkflow(for repo: Repo) {
      open(url: repo.githubURL())
    }

    func statusSymbolName(at date: Date = Date()) -> String {
      let combined = status.combinedState
      guard !combined.isEmpty else { return "questionmark.circle" }
      let index = Int(date.timeIntervalSinceReferenceDate / 1.5) % combined.count
      switch combined[index] {
        case .unknown: return "questionmark.circle"
        case .passing: return "checkmark.circle"
        case .failing: return "xmark.circle"
        case .queued: return "clock.arrow.circlepath"
        case .running: return "arrow.triangle.2.circlepath"
      }
    }
  }
#endif
