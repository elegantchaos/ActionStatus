// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import SwiftUIExtensions

public enum SortMode: String, CaseIterable {
    case name
    case state
    
    func sort<T>(_ repos: T) -> [Repo] where T: Collection, T.Element == Repo {
        switch self {
            case .name: return repos.sorted(by: \.name)
            case .state: return repos.sorted { r1, r2 in
                if (r1.state == r2.state) {
                    return r1.name < r2.name
                }
                
                return r1.state.rawValue > r2.state.rawValue
            }
        }
    }
}

extension SortMode: Labelled {
    public var label: String {
        switch self {
            case .name: return "Name"
            case .state: return "State"
        }
    }
}

