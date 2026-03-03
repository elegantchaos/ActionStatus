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
class TestEngine: AppEngine {
  var state: AppState = .uninitialised
  
  var constantService: ConstantService
  var slowService: SlowStartupService?
  
  var startupContinuation: CheckedContinuation<Void, any Error>?

  init() {
    constantService = ConstantService()
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
  
  func fakeFinishedStartup() {
    slowService = SlowStartupService()
    startupContinuation?.resume()
  }
  
  func fakeErrorStartup() {
    startupContinuation?.resume(throwing: TestError.fakeStartupError)
  }
  
  func fakeErrorRunning() {
    caughtError(TestError.fakeRunningError)
  }
  
  var startupInjector: StartupInjector {
    StartupInjector(engine: self)
  }
  
  var runningInjector: RunningInjector {
    RunningInjector(engine: self)
  }
  
  struct StartupInjector: ViewModifier {
    let engine: TestEngine
    
    func body(content: Content) -> some View {
      content
        .environment(engine.constantService)
    }
  }
  
  struct RunningInjector: ViewModifier {
    let engine: TestEngine

    func body(content: Content) -> some View {
      content
        .environment(engine.constantService)
        .environment(engine.slowService!)
    }
  }
}

enum TestError: Error {
  case fakeStartupError
  case fakeRunningError
}

@Observable
class ConstantService {
  
}

@Observable
class SlowStartupService {
  
}
