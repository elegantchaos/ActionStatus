// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 21/07/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class OneShotTimer {
    typealias Action = (Timer) -> ()
    var timer: Timer?
    
    public func cancel() -> Bool {
        let cancelled = timer != nil
        timer?.invalidate()
        timer = nil
        return cancelled
    }

    func schedule(after interval: TimeInterval, action: @escaping Action) {
        _ = cancel()
        modelChannel.log("Scheduled refresh for \(interval) seconds.")
        timer = .scheduledTimer(withTimeInterval: interval, repeats: false, block: action)
    }

}
