// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

class Option {
    let id: String
    let name: String
    
    init(_ id: String, name: String) {
        self.id = id
        self.name = name
    }
}

extension Option: Equatable {
    static func == (lhs: Option, rhs: Option) -> Bool {
        return lhs.name == rhs.name
    }
}

