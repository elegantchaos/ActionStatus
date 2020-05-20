//
//  GithubStatusUITests.swift
//  GithubStatusUITests
//
//  Created by Sam Deane on 05/02/2020.
//  Copyright © 2020 Elegant Chaos. All rights reserved.
//

import XCTest

class ActionStatusUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func makeScreenShot() {
        let screenshot = XCUIScreen.main.screenshot()
        let fullScreenshotAttachment = XCTAttachment(screenshot: screenshot)
        fullScreenshotAttachment.lifetime = .keepAlways

        add(fullScreenshotAttachment)
    }
    
    func testExample() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchEnvironment["UITesting"] = "YES"
        app.launch()
        
        Thread.sleep(forTimeInterval: 1)
        
        makeScreenShot()
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
                                
    }
    
    func anotherTest() {
        
    }
//
//    func testLaunchPerformance() {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
