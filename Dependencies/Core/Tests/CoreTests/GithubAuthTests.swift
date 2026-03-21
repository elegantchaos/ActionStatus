import Foundation
import Runtime
import Testing

@testable import Core
@testable import CoreUI

// MARK: - GithubCredentials

@MainActor
struct GithubCredentialsTests {
  @Test
  func initStoresAllFields() {
    let creds = GithubCredentials(login: "octocat", server: "api.github.com", token: "ghs_abc")
    #expect(creds.login == "octocat")
    #expect(creds.server == "api.github.com")
    #expect(creds.token == "ghs_abc")
  }

  @Test
  func equalityHoldsForSameValues() {
    let a = GithubCredentials(login: "u", server: "s", token: "t")
    let b = GithubCredentials(login: "u", server: "s", token: "t")
    #expect(a == b)
  }

  @Test
  func inequalityOnDifferentLogin() {
    let a = GithubCredentials(login: "alice", server: "s", token: "t")
    let b = GithubCredentials(login: "bob", server: "s", token: "t")
    #expect(a != b)
  }
}

// MARK: - GithubAuthState

@MainActor
struct GithubAuthStateTests {
  private let credentials = GithubCredentials(login: "octocat", server: "api.github.com", token: "tok")

  @Test
  func signedInCredentialsReturnsValue() {
    let state = GithubAuthState.signedIn(credentials)
    #expect(state.credentials == credentials)
  }

  @Test
  func otherStatesReturnNilCredentials() {
    #expect(GithubAuthState.signedOut.credentials == nil)
    #expect(GithubAuthState.signingIn.credentials == nil)
    #expect(GithubAuthState.validating(credentials).credentials == nil)
    #expect(GithubAuthState.awaitingApproval(userCode: "AB-CD", url: URL(string: "https://github.com/login/device")!).credentials == nil)
    #expect(GithubAuthState.invalidCredentials(credentials).credentials == nil)
    #expect(GithubAuthState.failed("oops").credentials == nil)
  }

  @Test
  func isSignedInOnlyForSignedInCase() {
    #expect(GithubAuthState.signedIn(credentials).isSignedIn)
    #expect(!GithubAuthState.signedOut.isSignedIn)
    #expect(!GithubAuthState.signingIn.isSignedIn)
    #expect(!GithubAuthState.failed("err").isSignedIn)
  }
}

// MARK: - AuthDebugScenario

@MainActor
struct AuthDebugScenarioTests {
  @Test
  func stateRoundTripsBackToScenario() {
    for scenario in AuthDebugScenario.allCases {
      #expect(AuthDebugScenario(state: scenario.state) == scenario)
    }
  }
}

// MARK: - AuthService

@MainActor
struct AuthServiceTests {
  private let credentials = GithubCredentials(login: "octocat", server: "api.github.com", token: "tok")

  @Test
  func stubStartsSignedOutByDefault() {
    let service = AuthService.stub()
    #expect(service.authState == .signedOut)
    #expect(!service.supportsDebugScenarios)
  }

  @Test
  func stubUsesExplicitInitialState() {
    let service = AuthService.stub(initialState: .signedIn(credentials))
    #expect(service.authState == .signedIn(credentials))
  }

  @Test
  func stubStartupIsNoOp() async {
    let service = AuthService.stub(initialState: .signedIn(credentials))
    await service.startup()
    #expect(service.authState == .signedIn(credentials))
  }

  @Test
  func stubStartSignInIsNoOp() {
    let service = AuthService.stub(initialState: .signedOut)
    service.startSignIn(server: "api.github.com", scopes: ["repo"])
    #expect(service.authState == .signedOut)
  }

  @Test
  func stubSignOutResetsToSignedOut() {
    let service = AuthService.stub(initialState: .signedIn(credentials))
    service.signOut()
    #expect(service.authState == .signedOut)
  }

  @Test
  func simulatedServicePublishesInitialScenario() {
    let service = AuthService.simulated(initialScenario: .invalidCredentials)
    #expect(service.authState == .invalidCredentials(AuthDebugScenario.sampleCredentials))
    #expect(service.activeDebugScenario == .invalidCredentials)
    #expect(service.supportsDebugScenarios)
  }

  @Test
  func simulatedServiceCanApplyScenario() {
    let service = AuthService.simulated(initialScenario: .signedOut)
    service.apply(debugScenario: .awaitingApproval)
    #expect(service.authState == .awaitingApproval(userCode: "AB-CD", url: AuthDebugScenario.approvalURL))
    #expect(service.activeDebugScenario == .awaitingApproval)
  }

  @Test
  func simulatedStartSignInMovesToSigningIn() {
    let service = AuthService.simulated(initialScenario: .signedOut)
    service.startSignIn()
    #expect(service.authState == .signingIn)
    #expect(service.activeDebugScenario == .signingIn)
  }

  @Test
  func simulatedSignOutMovesToSignedOut() {
    let service = AuthService.simulated(initialScenario: .signedIn)
    service.signOut()
    #expect(service.authState == .signedOut)
    #expect(service.activeDebugScenario == .signedOut)
  }
}

// MARK: - Engine auth mode selection

@MainActor
struct EngineAuthModeTests {
  @Test
  func unsetModesKeepNormalRefreshByDefault() {
    withEnvironment("TEST_AUTH", value: nil) {
      withEnvironment("TEST_REFRESH", value: nil) {
        #expect(Engine.makeRefreshType(runtime: Runtime()) == .normal)
      }
    }
  }

  @Test
  func authModeForcesRandomRefreshWhenRefreshModeIsUnset() {
    withEnvironment("TEST_AUTH", value: "simulated") {
      withEnvironment("TEST_REFRESH", value: nil) {
        #expect(Engine.makeRefreshType(runtime: Runtime()) == .random)
      }
    }
  }

  @Test
  func explicitRefreshModeRemainsIndependentOfAuthMode() {
    withEnvironment("TEST_AUTH", value: "simulated") {
      withEnvironment("TEST_REFRESH", value: "random") {
        #expect(Engine.makeRefreshType(runtime: Runtime()) == .random)
      }
    }
  }

  @Test
  func normalModeDefaultsToLiveAuthService() {
    withEnvironment("TEST_AUTH", value: nil) {
      let service = Engine.makeAuthService(runtime: Runtime(), refreshType: .normal)
      #expect(!service.supportsDebugScenarios)
      #expect(service.authState == .signedOut)
    }
  }

  @Test
  func normalModeUsesSimulatedAuthWhenRequested() {
    withEnvironment("TEST_AUTH", value: "simulated") {
      let service = Engine.makeAuthService(runtime: Runtime(), refreshType: .normal)
      #expect(service.supportsDebugScenarios)
      #expect(service.activeDebugScenario == .signedOut)
      #expect(service.authState == .signedOut)
    }
  }

  @Test
  func normalModePreservesLegacySignedInStubBehavior() {
    withEnvironment("TEST_AUTH", value: "1") {
      let service = Engine.makeAuthService(runtime: Runtime(), refreshType: .normal)
      #expect(!service.supportsDebugScenarios)
      #expect(service.authState == .signedIn(GithubCredentials(login: "test", server: "api.github.com", token: "test-token")))
    }
  }

  @Test
  func simulatedAuthOverridesRandomRefreshMode() {
    withEnvironment("TEST_AUTH", value: "simulated") {
      let service = Engine.makeAuthService(runtime: Runtime(), refreshType: .random)
      #expect(service.supportsDebugScenarios)
      #expect(service.activeDebugScenario == .signedOut)
      #expect(service.authState == .signedOut)
    }
  }

  @Test
  func simulatedAuthOverridesDisabledRefreshMode() {
    withEnvironment("TEST_AUTH", value: "simulated") {
      let service = Engine.makeAuthService(runtime: Runtime(), refreshType: .none)
      #expect(service.supportsDebugScenarios)
      #expect(service.activeDebugScenario == .signedOut)
      #expect(service.authState == .signedOut)
    }
  }

  @Test
  func unsetAuthStillUsesRefreshSpecificDefaults() {
    withEnvironment("TEST_AUTH", value: nil) {
      let randomService = Engine.makeAuthService(runtime: Runtime(), refreshType: .random)
      #expect(randomService.authState == .signedIn(GithubCredentials(login: "random-user", server: "api.github.com", token: "random-token")))

      let disabledService = Engine.makeAuthService(runtime: Runtime(), refreshType: .none)
      #expect(disabledService.authState == .signedOut)
    }
  }
}

// MARK: - Monitoring overlay

@MainActor
struct AuthMonitoringOverlayModelTests {
  @Test
  func overlayShowsForInactiveMonitoringStates() {
    let credentials = GithubCredentials(login: "octocat", server: "api.github.com", token: "tok")

    #expect(AuthMonitoringOverlayModel(state: .signedOut) != nil)
    #expect(AuthMonitoringOverlayModel(state: .validating(credentials)) != nil)
    #expect(AuthMonitoringOverlayModel(state: .invalidCredentials(credentials)) != nil)
    #expect(AuthMonitoringOverlayModel(state: .failed("oops")) != nil)
  }

  @Test
  func overlayDoesNotShowForActiveOrInFlightSignInStates() {
    let credentials = GithubCredentials(login: "octocat", server: "api.github.com", token: "tok")

    #expect(AuthMonitoringOverlayModel(state: .signingIn) == nil)
    #expect(AuthMonitoringOverlayModel(state: .awaitingApproval(userCode: "AB-CD", url: URL(string: "https://github.com/login/device")!)) == nil)
    #expect(AuthMonitoringOverlayModel(state: .signedIn(credentials)) == nil)
  }
}

// MARK: - Helpers

@MainActor
private func withEnvironment(_ key: String, value: String?, perform: () -> Void) {
  let previous = getenv(key).map { String(cString: $0) }

  if let value {
    setenv(key, value, 1)
  } else {
    unsetenv(key)
  }

  perform()

  if let previous {
    setenv(key, previous, 1)
  } else {
    unsetenv(key)
  }
}
