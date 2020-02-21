//
//  AppDelegate.swift
//  ActionStatusTV
//
//  Created by Developer on 13/02/2020.
//  Copyright © 2020 Elegant Chaos. All rights reserved.
//

import UIKit
import SwiftUI
import ApplicationExtensions

@UIApplicationMain
class AppDelegate: AppCommon {

    override func setup(withOptions options: BasicApplication.LaunchOptions) {
        super.setup(withOptions: options)

        // Create the SwiftUI view that provides the window contents.
        let app = AppDelegate.shared
        let contentView = app.makeContentView()

        // Use a UIHostingController as window root view controller.
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: contentView)
        self.window = window
        window.makeKeyAndVisible()
    }

}

