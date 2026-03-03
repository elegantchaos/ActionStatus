//
//  TestApplicationApp.swift
//  TestApplication
//
//  Created by Sam Deane on 03/03/2026.
//

import SwiftUI
import Application

@main
struct TestApplication: App {
  let engine: TestEngine
  
  init() {
    engine = TestEngine()
    engine.standardLoop()
  }
  
  var body: some Scene {
    WindowGroup {
      engine.rootView {
        VStack {
          ProgressView()
          Button("Finish Startup") {
            engine.fakeFinishedStartup()
          }
          Button("Throw Error In Startup") {
            engine.fakeErrorStartup()
          }
        }
      } running: {
        Text("Content Here")
        Button("Throw Error Whilst Running") {
          engine.fakeErrorRunning()
        }
      } error: { caughtError in
        let e = String(describing: caughtError)
        Text("Error \(e)")
        Button("Resume") {
          engine.recoverFromError()
        }
      }
    }
  }
}


@Observable
class TestEngine: Engine {
  var state: Application.State = .uninitialised

  var startupContinuation: CheckedContinuation<Void, any Error>?

  init() {
  }
  
  func initialise() throws {
  }

  func startup() async throws {
    try await withCheckedThrowingContinuation { continuation in
      startupContinuation = continuation
    }
  }

  func retry() async throws {
  }

  func shouldIgnore(error: any Error) -> Bool { false }

  func setState(_ state: Application.State) {
    self.state = state
  }
  
  func fakeFinishedStartup() {
    startupContinuation?.resume()
  }
  
  func fakeErrorStartup() {
    startupContinuation?.resume(throwing: TestError.fakeStartupError)
  }
  
  func fakeErrorRunning() {
    caughtError(TestError.fakeRunningError)
  }
}

enum TestError: Error {
  case fakeStartupError
  case fakeRunningError
}
