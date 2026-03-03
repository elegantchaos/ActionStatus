// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/10/2025.
//  Copyright © 2025 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import SwiftUI

public protocol Engine {
  func initialise() throws
  func startup() async throws
  func retry() async throws
  func shouldIgnore(error: Error) -> Bool
  func setState(_ state: State)
  var state: State { get set }
}

public extension Engine {
  func standardLoop() {
    advance()
  }

  func advance() {
    switch state {
      case .uninitialised:
        do {
          try initialise()
          setState(.starting)
          advance()
        } catch {
          caughtError(error)
        }
      case .starting:
        Task {
          do {
            try await startup()
            setState(.running)
          } catch {
            caughtError(error)
          }
        }
      default:
        break
    }
  }

  func caughtError(_ error: Error) {
    if !shouldIgnore(error: error) {
      setState(.error(error, state))
    }
  }

  func recoverFromError() {
    switch state {
      case .error(let error, let previousState):
        setState(previousState)
        do {
          try advance()
        } catch {
          caughtError(error)
        }
      default:
        break
    }
  }

  func rootView<S: View, R: View, E: View>(
    @ViewBuilder startup: () -> S,
    @ViewBuilder running: () -> R,
    @ViewBuilder error: (Error) -> E
  ) -> some View {
    Group {
      switch state {
        case .uninitialised, .starting:
          startup()
        case .running, .terminating:
          running()
        case .error(let e, let previousState):
          error(e)
      }
    }
  }


}
public indirect enum State {
  case uninitialised
  case starting
  case running
  case error(Error, State)
  case terminating
}
