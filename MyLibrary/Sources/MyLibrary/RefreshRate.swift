// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/08/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import SwiftUIExtensions

public enum RefreshRate: Int, CaseIterable {
        case automatic = 0
        case quick = 30
        case minute  = 60
        case fiveMinute = 300
        case tenMinute = 600

        var normalised: RefreshRate {
            self == .automatic ? RefreshRate.minute : self
        }
        
        var rate: TimeInterval {
            return TimeInterval(self.normalised.rawValue)
        }
    }

extension RefreshRate: Labelled {
    public var label: String {
        if self == .automatic {
            return "Default (\(normalised.label))"
        } else if rawValue < 60 {
            return "\(rawValue) seconds"
        } else {
            return "\(rawValue / 60) minutes"
        }
    }
}
