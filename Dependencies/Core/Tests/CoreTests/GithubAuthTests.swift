import Foundation
import Testing

@testable import Core

// MARK: - GithubCredentials

@MainActor
struct GithubCredentialsTests {
  /// Verifies that init stores all three fields correctly.
  @Test
  func initStoresAllFields() {
    let creds = GithubCredentials(login: "octocat", server: "api.github.com", token: "ghs_abc")
    #expect(creds.login == "octocat")
    #expect(creds.server == "api.github.com")
    #expect(creds.token == "ghs_abc")
  }

  /// Two credentials with the same values are equal.
  @Test
  func equalityHoldsForSameValues() {
    let a = GithubCredentials(login: "u", server: "s", token: "t")
    let b = GithubCredentials(login: "u", server: "s", token: "t")
    #expect(a == b)
  }

  /// Credentials differing by login are not equal.
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

  /// `.signedIn` exposes its credentials via the computed property.
  @Test
  func signedInCredentialsReturnsValue() {
    let state = GithubAuthState.signedIn(credentials)
    #expect(state.credentials == credentials)
  }

  /// Non-`.signedIn` states return nil credentials.
  @Test
  func otherStatesReturnNilCredentials() {
    #expect(GithubAuthState.signedOut.credentials == nil)
    #expect(GithubAuthState.signingIn.credentials == nil)
    #expect(GithubAuthState.validating(credentials).credentials == nil)
    #expect(GithubAuthState.awaitingApproval(userCode: "AB-CD", url: URL(string: "https://github.com/login/device")!).credentials == nil)
    #expect(GithubAuthState.invalidCredentials(credentials).credentials == nil)
    #expect(GithubAuthState.failed("oops").credentials == nil)
  }

  /// `isSignedIn` is true only for `.signedIn`.
  @Test
  func isSignedInOnlyForSignedInCase() {
    #expect(GithubAuthState.signedIn(credentials).isSignedIn)
    #expect(!GithubAuthState.signedOut.isSignedIn)
    #expect(!GithubAuthState.signingIn.isSignedIn)
    #expect(!GithubAuthState.failed("err").isSignedIn)
  }
}

// MARK: - StubAuthService

@MainActor
struct StubAuthServiceTests {
  private let credentials = GithubCredentials(login: "octocat", server: "api.github.com", token: "tok")

  /// Default init produces `.signedOut`.
  @Test
  func defaultInitIsSignedOut() {
    let stub = StubAuthService()
    #expect(stub.authState == .signedOut)
  }

  /// Init with explicit state publishes that state.
  @Test
  func initWithStatePublishesThatState() {
    let stub = StubAuthService(initialState: .signedIn(credentials))
    #expect(stub.authState == .signedIn(credentials))
  }

  /// `startup()` is a no-op — state is unchanged.
  @Test
  func startupIsNoOp() async {
    let stub = StubAuthService(initialState: .signedIn(credentials))
    await stub.startup()
    #expect(stub.authState == .signedIn(credentials))
  }

  /// `startSignIn(server:scopes:)` is a no-op — state is unchanged.
  @Test
  func startSignInIsNoOp() {
    let stub = StubAuthService(initialState: .signedOut)
    stub.startSignIn(server: "api.github.com", scopes: ["repo"])
    #expect(stub.authState == .signedOut)
  }

  /// `signOut()` always resets state to `.signedOut`.
  @Test
  func signOutResetsToSignedOut() {
    let stub = StubAuthService(initialState: .signedIn(credentials))
    stub.signOut()
    #expect(stub.authState == .signedOut)
  }

  /// Protocol extension `startSignIn()` delegates without changing stub state.
  @Test
  func protocolExtensionStartSignInIsNoOp() {
    let stub: any AuthService = StubAuthService(initialState: .signingIn)
    stub.startSignIn()
    #expect(stub.authState == .signingIn)
  }
}
