// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit

struct Repo: Equatable, Hashable {
    let name: String
    let owner: String
    let workflow: String
    let svg: String
    
    init(_ name: String, owner: String = "elegantchaos", workflow: String = "Tests") {
        self.name = name
        self.owner = owner
        self.workflow = workflow
        
        if let url = URL(string: "https://github.com/\(owner)/\(name)/workflows/\(workflow)/badge.svg"),
            let data = try? Data(contentsOf: url),
            let string = String(data: data, encoding: .utf8) {
            svg = string
        } else {
            svg = ""
        }
    }
    
    enum State {
        case unknown
        case failing
        case passing
    }
    
    var state: State {
        if svg.contains("failing") {
            return .failing
        } else if svg.contains("passing") {
            return .passing
        } else {
            return .unknown
        }
    }
    
    func badge() -> UIImage {
        let name: String
        switch state {
            case .unknown: name = "questionmark.circle"
            case .failing: name = "xmark.circle"
            case .passing: name = "checkmark.circle"
        }
        
        return UIImage(systemName: name) ?? UIImage()
    }

}
