// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/02/26.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(macOS)
  import AppKit
  import Core
  import SwiftUI

  extension TimeInterval {
    static let statusCycleInterval = 1.5
  }

  final class MacApplication: Engine, NSWindowDelegate, NSMenuDelegate {
    typealias StatusImageNames = [Repo.State: String]

    private let statusImageNames: StatusImageNames = [
      .unknown: "StatusUnknownSolid",
      .passing: "StatusPassingSolid",
      .failing: "StatusFailingSolid",
      .queued: "StatusQueuedSolid",
      .running: "StatusRunningSolid",
    ]

    private var mainWindow: NSWindow?
    private var statusItem: NSStatusItem?
    private var updateTimer: Timer?
    private var quitting = false

    override func setupDefaultSettings() {
      super.setupDefaultSettings()
      UserDefaults.standard.register(defaults: [
        .showInMenuKey: true,
        .showInDockKey: true,
      ])
    }

    override func setUp(withOptions options: LaunchOptions, completion: @escaping SetupCompletion) {
      super.setUp(withOptions: options) { [self] options in
        makeMainWindowIfNeeded()
        applyWindowAndMenuSettings()

        let timer = Timer(timeInterval: .statusCycleInterval, repeats: true) { [weak self] _ in
          self?.updateStatusItemImage()
        }

        RunLoop.main.add(timer, forMode: .default)
        updateTimer = timer

        completion(options)
      }
    }

    override func makeWindow() {
      makeMainWindowIfNeeded()
      showWindow(self)
    }

    override func loadSettings() {
      super.loadSettings()
      applyWindowAndMenuSettings()
    }

    override func updateRepoState() {
      super.updateRepoState()
      updateStatusItemImage()
    }

    override func reveal(url: URL) {
      NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    override func tearDown() {
      updateTimer?.invalidate()
      updateTimer = nil
      super.tearDown()
    }

    @objc func showPreferences() {
      sheetController.show {
        PreferencesView()
      }
      showWindow(self)
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
      makeMainWindowIfNeeded()
      mainWindow?.makeKeyAndOrderFront(sender)
      NSApp.activate(ignoringOtherApps: true)
    }

    @objc func handleQuit(_ sender: Any?) {
      quitting = true
      NSApp.terminate(sender)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
      false
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
      if quitting {
        return true
      }

      sender.orderOut(self)
      return false
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
      guard menu == statusItem?.menu else { return }
      menu.removeAllItems()

      for index in 0..<model.count {
        let title = status.name(forRepoWithIndex: index)
        let item = menu.addItem(withTitle: title, action: #selector(handleMenuItem(_:)), keyEquivalent: "")
        item.tag = index
        item.image = image(for: status.state(forRepoWithIndex: index))
      }

      menu.addItem(NSMenuItem.separator())
      menu.addItem(withTitle: "Show \(info.name)", action: #selector(showWindow(_:)), keyEquivalent: "")
      menu.addItem(withTitle: "Preferences…", action: #selector(showPreferences), keyEquivalent: ",")
      menu.addItem(withTitle: "Add Local Repos", action: #selector(addLocalRepos), keyEquivalent: "o")
      menu.addItem(withTitle: "Quit \(info.name)", action: #selector(handleQuit(_:)), keyEquivalent: "q")
    }

    @objc private func handleMenuItem(_ sender: Any?) {
      guard let item = sender as? NSMenuItem else { return }
      let repo = status.repo(withIndex: item.tag)
      open(url: repo.githubURL())
    }

    private func makeMainWindowIfNeeded() {
      guard mainWindow == nil else { return }

      let content = applyEnvironment(to: ContentView())
      let controller = NSHostingController(rootView: content)
      let window = NSWindow(contentViewController: controller)
      window.title = info.name
      window.setContentSize(NSSize(width: 820, height: 620))
      window.minSize = NSSize(width: 420, height: 320)
      window.delegate = self
      window.center()
      window.setFrameAutosaveName("MainWindow")
      mainWindow = window
    }

    private func applyWindowAndMenuSettings() {
      let showInDock = UserDefaults.standard.bool(forKey: .showInDockKey)
      let showInMenu = UserDefaults.standard.bool(forKey: .showInMenuKey)

      let activation: NSApplication.ActivationPolicy = showInDock ? .regular : .accessory
      if NSApp.activationPolicy() != activation {
        NSApp.setActivationPolicy(activation)
      }

      if showInMenu {
        setupStatusItemIfNeeded()
      } else {
        removeStatusItemIfNeeded()
      }

      updateStatusItemImage()
    }

    private func setupStatusItemIfNeeded() {
      guard statusItem == nil else { return }
      let item = NSStatusBar.system.statusItem(withLength: 22)
      let menu = NSMenu(title: info.name)
      menu.delegate = self
      item.menu = menu
      statusItem = item
    }

    private func removeStatusItemIfNeeded() {
      guard let statusItem else { return }
      NSStatusBar.system.removeStatusItem(statusItem)
      self.statusItem = nil
    }

    private func updateStatusItemImage() {
      guard let button = statusItem?.button else { return }

      let combined = status.combinedState
      guard !combined.isEmpty else {
        button.image = image(for: .unknown)
        return
      }

      let index = Int(Date.timeIntervalSinceReferenceDate / .statusCycleInterval) % combined.count
      button.image = image(for: combined[index])
    }

    private func image(for state: Repo.State) -> NSImage? {
      guard let name = statusImageNames[state], let image = NSImage(named: name) else {
        return NSImage(systemSymbolName: "questionmark.circle", accessibilityDescription: "Unknown")
      }
      image.size = NSSize(width: 18, height: 18)
      return image
    }
  }
#endif
