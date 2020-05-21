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
        makeScreenShot("01-main")

//        let toggleEditing = app.buttons["toggleEditing"]
//        XCTAssert(toggleEditing.exists)
//        toggleEditing.tap()
//        makeScreenShot("editing mode")
//        toggleEditing.tap()

        let firstRow = app.staticTexts["Datastore"]
        XCTAssertTrue(firstRow.exists)

        firstRow.press(forDuration: 1.0)
        makeScreenShot("02-contextual")

        let edit = app.buttons["Edit…"].firstMatch
        XCTAssertTrue(edit.waitForExistence(timeout: 5))
        edit.tap()

        let header = app.staticTexts["formHeader"]
        XCTAssert(header.waitForExistence(timeout: 1))
        makeScreenShot("03-editor")
        
        let cancel = app.buttons["cancel"].firstMatch
        XCTAssert(cancel.exists)
        cancel.tap()

        firstRow.press(forDuration: 1.0)
        
        let generate = app.buttons["Generate Workflow…"].firstMatch
        XCTAssertTrue(generate.waitForExistence(timeout: 5))
        generate.tap()
 
        XCTAssertTrue(header.waitForExistence(timeout: 1))
        makeScreenShot("04-generate")
    }
}
