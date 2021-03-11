// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreServices

#if targetEnvironment(macCatalyst)
import Displays
#endif

class ScreenshotUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    func cleanScreenshot() -> XCUIScreenshot {
        #if targetEnvironment(macCatalyst)
        let main = XCUIScreen.main
        for screen in XCUIScreen.screens {
            if screen != main {
                return screen.screenshot()
            }
        }
        #endif
        
        return XCUIScreen.main.screenshot()
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

        #if targetEnvironment(macCatalyst)
        for display in Display.active {
            if !display.isMain {
                let move = app.menuItems["Move to \(display.name)"]
                if move.exists {
                    move.tap()
                }
            }
        }
        #endif
        
        #if os(tvOS)
        if app.keys.element(boundBy: 0).exists {
            app.typeText("")
        }
        #endif
        
        let firstRow = app.staticTexts["Datastore"]
        XCTAssertTrue(firstRow.waitForExistence(timeout: 5))
        makeScreenShot("01-main")

        #if !os(tvOS)
//        let toggleEditing = app.buttons["toggleEditing"]
//        XCTAssert(toggleEditing.exists)
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
        XCTAssert(status.exists)
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
        if item.exists {
            item.tap()
        }
        #endif
    }
    
    func unhideApplications() {
        #if os(macOS) || targetEnvironment(macCatalyst)
        let item = menuItems["unhideAllApplications:"]
        if item.exists {
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
