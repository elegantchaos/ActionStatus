// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

class Updater: ObservableObject {
    @Published var progress: Double = 0
    @Published var status: String = ""
    @Published var hasUpdate: Bool = false

    func installUpdate() { }
    func skipUpdate() { }
    func ignoreUpdate() { }
}

struct SparkleView: View {
    let updater: Updater
    
    var body: some View {
        HStack {
            Button(action: updater.installUpdate) { Text("Update") }
            Button(action: updater.skipUpdate) { Text("Skip") }
            Button(action: updater.ignoreUpdate) { Text("Later") }
        }.statusStyle()
    }
    
}

extension Color {
    static var defaultProgressBackground: Color { return Color(UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)) }
    static var defaultProgressForeground: Color { return .black }
}

struct SparkleProgressView: View {
    @ObservedObject var updater: Updater
    
    let height: CGFloat = 16.0
    
    private let backgroundEnabled: Bool
    private let backgroundColor: Color
    private let foregroundColor: Color
    
    init(updater: Updater, backgroundEnabled: Bool = true, backgroundColor: Color = .defaultProgressBackground, foregroundColor: Color = .defaultProgressForeground) {
        self.updater = updater
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
