// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/05/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation


/// Randomly changes the state of repos. Useful for testing the UI.

public class RandomisingRefreshController: RefreshController {
    internal let timer: OneShotTimer
    
    override public init(model: Model, context: ViewContext) {
        self.timer = OneShotTimer()
        super.init(model: model, context: context)
    }
    
    override func startRefresh() {
        refreshChannel.log("Resumed refresh.")
        timer.schedule(after: 0) { _ in
            self.doRefresh()
        }
    }
    
    override func cancelRefresh() {
        refreshChannel.log("Paused refresh.")
        if timer.cancel() {
            refreshChannel.log("Cancelled refresh.")
        }
    }
}

internal extension RandomisingRefreshController {
    func doRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(1))) { [self] in
            switch state {
                case .running:
                    refreshChannel.log("Completed Refresh")
                    if let id = self.model.items.randomElement()?.value.id, let newState = Repo.State.allCases.randomElement() {
                        self.model.update(repoWithID: id, state: newState)
                    }
                    doRefresh()
                    
                default:
                    refreshChannel.log("Skipping Update (We Are Paused)")
            }
        }
    }
}
