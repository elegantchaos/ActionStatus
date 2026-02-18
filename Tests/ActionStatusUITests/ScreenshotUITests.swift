// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Core
import CoreServices
import XCTest

#if canImport(AppKit)
  import AppKit
#endif

class ScreenshotUITests: XCTestCase {
  var urls: [URL] = []

  override func setUp() {
    continueAfterFailure = false
  }

  var screenshotsURL: URL {
    let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Screenshots")
    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: [:])
    return url
  }

  func cleanScreenshot() -> XCUIScreenshot {
    let screens = XCUIScreen.screens
    let screen: XCUIScreen
    #if os(macOS)
      if let string = ProcessInfo.processInfo.environment["UITestScreen"], let index = Int(string), index < screens.count {
        screen = screens[index]
      } else {
        screen = screens.last!
      }
    #else
      screen = screens.first!
    #endif

    return screen.screenshot()
  }

  func makeScreenShot(_ name: String) {
    let screenshot = cleanScreenshot()
    let data = screenshot.pngRepresentation
    let url = screenshotsURL.appendingPathComponent(name).appendingPathExtension("png")
    do {
      try data.write(to: url)
      urls.append(url)
    } catch {
      print("Screenshot \(name) failed.")
    }

    let attachment = XCTAttachment(uniformTypeIdentifier: kUTTypePNG as String, name: name, payload: screenshot.pngRepresentation, userInfo: [:])
    attachment.lifetime = .keepAlways
    add(attachment)
  }

  func testMakeScreenshots() {
    // UI tests must launch the application that they test.
    let app = XCUIApplication()
    app.launchEnvironment.isTestingUI = true
    app.launchEnvironment["UITestScreen"] = ProcessInfo.processInfo.environment["UITestScreen"]
    //        app.launchEnvironment["Screenshots"] = screenshotsURL.absoluteString // the app will open this folder when it quits

    app.launch()
    app.hideOtherApplications()

    #if os(tvOS)
      if app.keys.element(boundBy: 0).waitForExistence(timeout: 1.0) {
        app.typeText("")
      }
    #endif

    let firstRow = app.buttons["CollectionExtensions"]
    XCTAssertTrue(firstRow.waitForExistence(timeout: 5))
    makeScreenShot("01-main")

    #if !os(tvOS)
      //        let toggleEditing = app.buttons["toggleEditing"]
      //        XCTAssert(toggleEditing.waitForExistence(timeout: 1.0))
      //        toggleEditing.tap()
      //        makeScreenShot("editing mode")
      //        toggleEditing.tap()

      app.showContextMenu(for: firstRow, highlighting: "Settings…")
      makeScreenShot("02-contextual")

      app.selectContextMenuItem("Settings…")
      let cancel = app.buttons["Cancel"].firstMatch
      XCTAssert(cancel.waitForExistence(timeout: 1))
      makeScreenShot("03-editor")
      cancel.tap()
    #endif

    #if os(macOS)
      let status = app.statusItems["ActionStatusStatusMenu"]
      XCTAssert(status.waitForExistence(timeout: 1.0))
      status.tap()
      makeScreenShot("05-status")
    #endif

    //        app.unhideApplications()
    app.quit()

    let names = urls.map({ $0.deletingPathExtension().lastPathComponent }).joined(separator: ", ")
    print("\n\n***********\nScreenshots \(names) logged to \(screenshotsURL)\n\n")
  }

  func testElements() {
    let app = XCUIApplication()
    app.launchEnvironment.isTestingUI = true
    app.launch()
    for element in app.statusItems.allElementsBoundByAccessibilityElement {
      print(element.identifier)
    }

  }
}

extension XCUIApplication {
  func showContextMenu(for row: XCUIElement, highlighting: String? = nil) {
    #if !os(tvOS)
      #if os(macOS)
        row.rightClick()
        if let name = highlighting {
          let item = menuItems[name].firstMatch
          XCTAssertTrue(item.waitForExistence(timeout: 5))
          item.hover()
        }
      #else
        row.press(forDuration: 1.0)
      #endif
    #endif
  }

  func selectContextMenuItem(_ name: String) {
    #if !os(tvOS)
      #if os(macOS)
        let item = menuItems[name].firstMatch
      #else
        let item = buttons[name].firstMatch
      #endif
      XCTAssertTrue(item.waitForExistence(timeout: 5))
      item.tap()
    #endif
  }

  func hideOtherApplications() {
    #if os(macOS)
      let item = menuItems["hideOtherApplications:"]
      if item.waitForExistence(timeout: 1.0) {
        item.tap()
      }
    #endif
  }

  func unhideApplications() {
    #if os(macOS)
      let item = menuItems["unhideAllApplications:"]
      if item.waitForExistence(timeout: 1.0) {
        item.tap()
      }
    #endif
  }

  func quit() {
    #if os(macOS)
      let item = menuItems["handleQuit:"]
      if item.waitForExistence(timeout: 1.0) {
        item.tap()
      }
    #endif
  }

}

/*
 hide finder icons

 defaults write com.apple.finder CreateDesktop false
 killall Finder

 mac screenshot sizes

 1280 x 800, 1440 x 900, 2560 x 1600, and 2880 x 1800


 */
