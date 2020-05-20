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
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(uniformTypeIdentifier: kUTTypePNG as String, name: name, payload: screenshot.pngRepresentation, userInfo: [:])
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testMakeScreenshots() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchEnvironment.isTestingUI = true
        app.launch()
        
        Thread.sleep(forTimeInterval: 1)
        makeScreenShot("main")

        let item = app.buttons["toggleEditing"]
        XCTAssert(item.exists)
        item.tap()
        makeScreenShot("editing mode")

        let edit = app.buttons["editButton"].firstMatch
        edit.tap()
        
        let header = app.staticTexts["formHeader"]
        XCTAssert(header.waitForExistence(timeout: 1))
        makeScreenShot("editor")
    }
}
