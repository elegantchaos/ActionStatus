// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 21/07/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Logger

public let refreshChannel = Channel("com.elegantchaos.actionstatus.Refresh")

public enum RefreshState {
    case running
    case paused(Int)
}

public class RefreshController {
    internal let model: Model
    internal let context: ViewContext
    internal var state: RefreshState = .paused(1)

    public init(model: Model, context: ViewContext) {
        self.model = model
        self.context = context
    }

    internal func startRefresh() { fatalError("needs overriding") }
    internal func cancelRefresh() { fatalError("needs overriding") }
}

public extension RefreshController {
    func pause() {
        DispatchQueue.main.async { [self] in
            switch state {
                case .paused(let level):
                    state = .paused(level + 1)
                    
                case .running:
                    state = .paused(1)
                    cancelRefresh()
            }
        }
    }
    
    func resume() {
        DispatchQueue.main.async { [self] in
            switch state {
                case .paused(let level):
                    if level == 1 {
                        state = .running
                        startRefresh()
                    } else {
                        state = .paused(level - 1)
                    }
                case .running:
                    break
            }
        }
    }
}
