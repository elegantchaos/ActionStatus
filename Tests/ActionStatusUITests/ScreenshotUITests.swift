// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import ActionStatusCore
import CoreServices

class ScreenshotUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    func makeScreenShot(_ name: String) {
        var n = 1
        let main = XCUIScreen.main
        for screen in XCUIScreen.screens {
            if screen != main {
            let screenshot = screen.screenshot()
            let attachment = XCTAttachment(uniformTypeIdentifier: kUTTypePNG as String, name: "\(name)-\(n)", payload: screenshot.pngRepresentation, userInfo: [:])
            attachment.lifetime = .keepAlways
            add(attachment)
            n += 1
            }
        }
    }
    
    func testMakeScreenshots() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchEnvironment.isTestingUI = true
        app.launch()
        app.hideOtherApplications()

        let firstRow = app.staticTexts["Datastore"]
        XCTAssertTrue(firstRow.waitForExistence(timeout: 5))
        makeScreenShot("01-main")

        #if !os(tvOS)
//        let toggleEditing = app.buttons["toggleEditing"]
//        XCTAssert(toggleEditing.exists)
//        toggleEditing.tap()
//        makeScreenShot("editing mode")
//        toggleEditing.tap()

        firstRow.showContextMenu()
        makeScreenShot("02-contextual")

        app.selectContextMenuItem("Edit…")
        let header = app.staticTexts["formHeader"]
        XCTAssert(header.waitForExistence(timeout: 1))
        makeScreenShot("03-editor")
        
        let cancel = app.buttons["cancel"].firstMatch
        XCTAssert(cancel.exists)
        cancel.tap()

        firstRow.showContextMenu()
        app.selectContextMenuItem("Generate Workflow…")
 
        XCTAssertTrue(header.waitForExistence(timeout: 1))
        makeScreenShot("04-generate")
        #endif

        app.unhideApplications()
    }
    
    func testElements() {
        let app = XCUIApplication()
        app.launchEnvironment.isTestingUI = true
        app.launch()
        for element in app.menuItems.allElementsBoundByAccessibilityElement {
            print(element.identifier)
        }

    }
}

extension XCUIElement {
    func showContextMenu() {
        #if targetEnvironment(macCatalyst)
        rightClick()
        #else
        press(forDuration: 1.0)
        #endif
    }
    
}

extension XCUIApplication {
    func selectContextMenuItem(_ name: String) {
        #if targetEnvironment(macCatalyst)
        let item = menuItems[name].firstMatch
        #else
        let item = buttons[name].firstMatch
        #endif
        XCTAssertTrue(item.waitForExistence(timeout: 5))
        item.tap()
    }
    
    func hideOtherApplications() {
        let item = menuItems["hideOtherApplications:"].firstMatch
        XCTAssertTrue(item.exists)
        item.tap()
    }
    
    func unhideApplications() {
        let item = menuItems["unhideAllApplications:"].firstMatch
        XCTAssertTrue(item.exists)
        item.tap()
    }
}
