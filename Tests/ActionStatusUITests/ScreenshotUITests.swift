// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreServices
import Core

class ScreenshotUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    func cleanScreenshot() -> XCUIScreenshot {
        let screens = XCUIScreen.screens
        let screen: XCUIScreen
        if let string = ProcessInfo.processInfo.environment["UITestScreen"], let index = Int(string), index < screens.count {
            screen = screens[index]
        } else {
            screen = screens.last!
        }
        
        return screen.screenshot()
    }
    
    func makeScreenShot(_ name: String) {
        let screenshot = cleanScreenshot()
        let attachment = XCTAttachment(uniformTypeIdentifier: kUTTypePNG as String, name: name, payload: screenshot.pngRepresentation, userInfo: [:])
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testMakeScreenshots() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchEnvironment.isTestingUI = true
        app.launch()
        app.hideOtherApplications()

        #if os(tvOS)
        if app.keys.element(boundBy: 0).waitForExistence(timeout: 1.0) {
            app.typeText("")
        }
        #endif
        
        let firstRow = app.staticTexts["CollectionExtensions"]
        XCTAssertTrue(firstRow.waitForExistence(timeout: 5))
        makeScreenShot("01-main")

        #if !os(tvOS)
//        let toggleEditing = app.buttons["toggleEditing"]
//        XCTAssert(toggleEditing.waitForExistence(timeout: 1.0))
//        toggleEditing.tap()
//        makeScreenShot("editing mode")
//        toggleEditing.tap()

        app.showContextMenu(for: firstRow, highlighting: "Edit…")
        makeScreenShot("02-contextual")

        app.selectContextMenuItem("Edit…")
        let cancel = app.buttons["cancel"].firstMatch
        XCTAssert(cancel.waitForExistence(timeout: 1))
        makeScreenShot("03-editor")
        cancel.tap()

        app.showContextMenu(for: firstRow)
        app.selectContextMenuItem("Generate Workflow…")
 
        XCTAssert(cancel.waitForExistence(timeout: 1))
        makeScreenShot("04-generate")
        cancel.tap()
        #endif

        #if targetEnvironment(macCatalyst)
        let status = app.statusItems["ActionStatusStatusMenu"]
        XCTAssert(status.waitForExistence(timeout: 1.0))
        status.tap()
        makeScreenShot("05-status")
        #endif
        
        app.unhideApplications()
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
        #if targetEnvironment(macCatalyst)
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
        #if targetEnvironment(macCatalyst)
        let item = menuItems[name].firstMatch
        #else
        let item = buttons[name].firstMatch
        #endif
        XCTAssertTrue(item.waitForExistence(timeout: 5))
        item.tap()
        #endif
    }
    
    func hideOtherApplications() {
        #if os(macOS) || targetEnvironment(macCatalyst)
        let item = menuItems["hideOtherApplications:"]
        if item.waitForExistence(timeout: 1.0) {
            item.tap()
        }
        #endif
    }
    
    func unhideApplications() {
        #if os(macOS) || targetEnvironment(macCatalyst)
        let item = menuItems["unhideAllApplications:"]
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
