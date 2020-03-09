// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct SparkleProgressView: View {
    @EnvironmentObject var updater: Updater
    
    let height: CGFloat = 16.0
    
    private let backgroundEnabled: Bool
    private let backgroundColor: Color
    private let foregroundColor: Color
    
    init(backgroundEnabled: Bool = true, backgroundColor: Color = .defaultProgressBackground, foregroundColor: Color = .defaultProgressForeground) {
        self.backgroundEnabled = backgroundEnabled
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometryReader in
                if self.backgroundEnabled {
                    Capsule()
                        .frame(height: self.height)
                        .foregroundColor(self.backgroundColor)
                }
                
                Capsule()
                    .frame(width: geometryReader.size.width * CGFloat(self.updater.progress), height: self.height)
                    .foregroundColor(self.foregroundColor)
                    .animation(.easeIn)
            }
        }.frame(height: height)
    }
}

extension Color {
    static var defaultProgressBackground: Color { return Color(UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)) }
    static var defaultProgressForeground: Color { return .black }
}
