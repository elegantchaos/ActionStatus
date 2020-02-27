// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 27/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct SparkleView: View {
    let driver: ActionStatusSparkleDriver
    
    var body: some View {
        HStack {
            Button(action: driver.installUpdate) { Text("Update") }
            Button(action: driver.skipUpdate) { Text("Skip") }
            Button(action: driver.ignoreUpdate) { Text("Later") }
        }.statusStyle()
    }
    
}

extension Color {
    static var defaultProgressBackground: Color { return Color(UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)) }
    static var defaultProgressForeground: Color { return .black }
}

struct SparkleProgressView: View {
    @ObservedObject var driver: ActionStatusSparkleDriver

    private let backgroundEnabled: Bool
    private let backgroundColor: Color
    private let foregroundColor: Color

    init(driver: ActionStatusSparkleDriver, backgroundEnabled: Bool = true, backgroundColor: Color = .defaultProgressBackground, foregroundColor: Color = .defaultProgressForeground) {
        self.driver = driver
        self.backgroundEnabled = backgroundEnabled
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        ZStack {
            // 2
            GeometryReader { geometryReader in
                // 3
                if self.backgroundEnabled {
                    Capsule()
                        .foregroundColor(self.backgroundColor) // 4
                }
                    
                Capsule()
                    .frame(width: geometryReader.size.width) // 5
                    .foregroundColor(self.foregroundColor) // 6
                    .animation(.easeIn) // 7
            }
        }
    }
    
}
