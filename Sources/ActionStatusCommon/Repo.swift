// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct Repo: Identifiable, Equatable {
//    static func == (lhs: Repo, rhs: Repo) -> Bool {
//        return (lhs.name == rhs.name) && (lhs.owner == rhs.owner) && (lhs.workflow == rhs.workflow)
//    }
//
//    func hash(into hasher: inout Hasher) {
//        name.hash(into: &hasher)
//        owner.hash(into: &hasher)
//        workflow.hash(into: &hasher)
//    }
    
    enum State: Int {
        case unknown = 0
        case failing = 1
        case passing = 2
    }

    let id: UUID
    var name: String
    var owner: String
    var workflow: String
    var svg: String = ""
    
    init() {
        id = UUID()
        name = "Unknown Repo"
        owner = "Unknow Owner"
        workflow = "Tests"
    }
    
    init(_ name: String, owner: String, workflow: String, id: UUID? = nil, state: State? = nil) {
        self.id = id ?? UUID()
        self.name = name
        self.owner = owner
        self.workflow = workflow
        
        switch state {
            case .passing: svg = "passing"
            case .failing: svg = "failing"
            default: svg = ""
        }

        svg = ""
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
    
    var badgeName: String {
        let name: String
        switch state {
            case .unknown: name = "questionmark.circle"
            case .failing: name = "xmark.circle"
            case .passing: name = "checkmark.circle"
        }
        return name
    }

    var statusColor: Color {
        switch state {
            case .unknown: return .black
            case .failing: return .red
            case .passing: return .green
        }
    }
    
    mutating func reload() {
        if let url = URL(string: "https://github.com/\(owner)/\(name)/workflows/\(workflow)/badge.svg"),
            let data = try? Data(contentsOf: url),
            let string = String(data: data, encoding: .utf8) {
            svg = string
        }
    }
}
