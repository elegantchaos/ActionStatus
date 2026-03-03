// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/10/2025.
//  Copyright © 2025 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import SwiftUI

@MainActor public protocol AppEngine: AnyObject {
  /// Perform one-time, synchronous startup.
  /// This should be as quick as possible, to avoid a delay
  /// before the app shows any UI
  func initialise() throws

  /// Perform asychronous startup.
  /// Whilst the app is doing this, it will be in the `.starting`
  /// state, and will be showing the startup UI.
  func startup() async throws

  /// Perform any optional retry cleanup
  func retry() async throws

  /// Should an error be ignored?
  /// If this returns false, the error will put the app
  /// into the .error state and show the error ui
  /// If it returns false, the app will continue in the state
  /// it was previously in.
  func shouldIgnore(error: Error) -> Bool

  /// The state that the app is in.
  var state: AppState { get set }

  /// A view modifier which injects environment into a view.
  /// It should assume that the engine isn't fully started yet,
  /// and so (for example) it may not inject services that
  /// could still be starting.
  associatedtype StartupInjector: ViewModifier

  /// Returns a modifier which injects environment.
  var startupInjector: StartupInjector { get }

  /// A view modifier which injects environment into a view.
  /// It can assume that the engine is fully started,
  /// and so (for example) it can force unwrap and inject optional
  /// services that were creating during startup.
  associatedtype RunningInjector: ViewModifier

  /// Returns a modifier which injects environment.
  var runningInjector: RunningInjector { get }

}

@MainActor public extension AppEngine {
  func standardLoop() {
    advance()
  }

  func advance() {
    switch state {
      case .uninitialised:
        do {
          try initialise()
          state = .starting
          advance()
        } catch {
          caughtError(error)
        }
      case .starting:
        Task {
          do {
            try await startup()
            state = .running
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
      state = .error(error, state)
    }
  }

  func recoverFromError() {
    switch state {
      case .error(_, let previousState):
        state = previousState
        advance()
      default:
        break
    }
  }

  func rootView<S: View, R: View, E: View>(
    @ViewBuilder running: () -> R,
    @ViewBuilder startup: () -> S = { DefaultStartupView() },
    @ViewBuilder error: (Error, AppState) -> E = { e, s in DefaultErrorView(e, s) }
  ) -> some View {
    Group {
      switch state {
        case .uninitialised, .starting:
          startup()
            .modifier(startupInjector)
        case .running, .terminating:
          running()
            .modifier(runningInjector)
        case .error(let e, let previousState):
          error(e, previousState)
      }
    }
  }
}

public struct DefaultStartupView: View {
  public init() { }
  public var body: some View {
    ProgressView()
  }
}

public struct DefaultErrorView: View {
  let error: Error
  let previousState: AppState
  
  public init(_ error: Error, _ previousState: AppState) {
    self.error = error
    self.previousState = previousState
  }
  
  public var body: some View {
    let errorDesc = String(describing: error)
    Text("Error: \(errorDesc)")
  }
}
