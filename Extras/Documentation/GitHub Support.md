# GitHub Support

This document describes how ActionStatus integrates with GitHub: authentication, credential storage, status refresh, and the conventions that keep each concern in the right layer.

---

## Architecture overview

GitHub support spans two Swift package targets:

| Target | Allowed dependencies | Responsibilities |
|--------|---------------------|-----------------|
| `Core` | Foundation, Logger, Octoid | Auth state machine, refresh scheduling, protocol definitions |
| `CoreUI` | Core + SwiftUI, Keychain, UserDefaults | Engine, credential persistence, settings observation, UI |

**Rule:** `Core` never reads `UserDefaults` or `Keychain` directly. `CoreUI` owns all persistence and pushes clean value types into Core services.

---

## Authentication

### Types

| Type | Location | Purpose |
|------|----------|---------|
| `GithubCredentials` | Core | Value type: `login`, `server`, `token` |
| `GithubAuthState` | Core | 7-case enum; single source of truth for auth state |
| `AuthService` | Core | Protocol; published `authState`, `startup()`, `startSignIn(server:scopes:)`, `signOut()` |
| `GithubAuthService` | Core | Live conformer; Keychain-backed, drives the device-code flow |
| `StubAuthService` | Core | Canned conformer used by previews and `TEST_AUTH` env builds |

### Auth state machine

```
signedOut ──startSignIn()──► signingIn
                              │
                              ▼
                        awaitingApproval(userCode:url:)
                              │
                    ┌─ ok ───┤
                    ▼         └─ error/cancel ──► failed / signedOut
               signedIn(GithubCredentials)
                    │
                    │ startup() validates stored credentials
                    ├─ valid ───────────────────────────────► signedIn
                    └─ invalid ─────────────────────────────► invalidCredentials
```

`invalidCredentials` retains the credentials so the user can see who they were signed in as before signing out.

### Sign-in flow (GitHub Device Authorization)

1. `startSignIn(server:scopes:)` transitions state to `.signingIn` and spawns an internal Task.
2. `GithubDeviceAuthenticator.startAuthorization(scopes:)` requests a device code from GitHub.
3. State transitions to `.awaitingApproval(userCode:url:)` — the UI opens the verification URL in a browser and shows the code.
4. `GithubDeviceAuthenticator.pollForUser(authorization:)` polls until the user approves.
5. On success, `GithubAuthService` persists the resulting `GithubCredentials` to Keychain and transitions to `.signedIn`.

### Credential persistence

`GithubAuthService` stores a single Keychain entry:

- **Account:** `"github"` (fixed)
- **Server:** configurable `keychainID`, defaulting to `"actionstatus.elegantchaos.com"`
- **Password:** JSON-encoded `{ login, server, token }`

Using a fixed account/server pair means only one credential set is stored at a time. The full `GithubCredentials` — including the actual API server hostname — lives inside the JSON, so it survives without requiring additional UserDefaults keys.

### Startup validation

At app launch, `GithubAuthService.startup()` reads the Keychain entry and calls `GithubDeviceAuthenticator.validateToken(_:)` to confirm it is still valid. If validation succeeds, state becomes `.signedIn`; if it fails, `.invalidCredentials` is set so the UI can display a warning without discarding the stored login.

### Injecting auth into the SwiftUI environment

`AuthService` is available as an environment value via `\.authService`:

```swift
@Environment(\.authService) private var authService
```

The default value is `StubAuthService()` (signed-out, no-op) so plain Xcode previews work without any setup. The live `Engine` injects `GithubAuthService`; preview hosts and tests inject `StubAuthService(initialState:)`.

For builds with the `TEST_AUTH` environment variable set, `Engine` injects a pre-signed-in `StubAuthService` so UI tests can skip the OAuth flow.

---

## Refresh

### Types

| Type | Location | Purpose |
|------|----------|---------|
| `RefreshSettings` | Core | Value snapshot: `server`, `token`, `interval` — produced when signed in |
| `RefreshService` | Core | Schedules and manages the active `RefreshController` |
| `OctoidRefreshController` | Core | GitHub API poller built on the Octoid library |
| `LastEventStore` | Core | Protocol: async get/set of last-seen event timestamps |
| `UserDefaultsLastEventStore` | CoreUI | Live `LastEventStore` backed by `UserDefaults` |

### Refresh lifecycle

`RefreshService` has three modes set at initialisation from `MetadataService`:

| Mode | Controller | Used when |
|------|-----------|-----------|
| `.normal` | `OctoidRefreshController` | Live builds |
| `.random` | `RandomisingRefreshController` | Test builds (`TEST_REFRESH=random`) |
| `.none` | — | UI testing builds |

For `.normal` mode, `RefreshService.startup()` begins observing `authService.authState` via `withObservationTracking`. When the state becomes `.signedIn(credentials)`, the service snapshots the credentials plus the current interval into a `RefreshSettings` value and creates (or recreates) the controller. When the state leaves `.signedIn`, the controller is torn down. This means the refresh controller tracks auth state reactively without polling.

For `.random` and `.none` modes, `startup()` creates (or skips) the controller immediately without auth.

### Interval changes

`Engine` observes `UserDefaults` changes via `onActionStatusSettingsChanged` and calls `refreshService.apply(interval:)` whenever the user changes the refresh interval in Preferences. The service forwards the new rate to any active controller without restarting it.

### Last-event deduplication

`OctoidRefreshController` passes each repository's last-seen event timestamp to the GitHub API so it only processes new events. Timestamps are persisted via the injected `LastEventStore`. `UserDefaultsLastEventStore` (CoreUI) is the live implementation; the async protocol interface prevents Core from taking a compile-time dependency on UserDefaults.

### App lifecycle pause/resume

`RefreshService.pauseRefresh()` and `resumeRefresh()` are called from SwiftUI views (e.g. `EditView`, `PreferencesForm`) when the user enters an editing mode. For `.normal` mode, `resumeRefresh()` resumes the existing controller if one exists; auth observation manages its creation. For other modes, the controller is recreated if it was nil.

---

## Settings

Settings that affect Core services are stored in `UserDefaults` (via `AppStorage` in the UI) and pushed into services by `Engine` (CoreUI). Core services never read UserDefaults directly.

| Setting key | Type | Pushed to |
|-------------|------|-----------|
| `SortMode` | `SortMode` | `StatusService.apply(sortMode:)` |
| `RefreshInterval` | `RefreshRate` | `RefreshService.apply(interval:)` |

Engine reads initial values on `startup()` and then subscribes to `UserDefaults.didChangeNotification` for the remainder of the session.

---

## Module dependency summary

```
Core
├── GithubCredentials          (value type)
├── GithubAuthState            (enum)
├── AuthService                (protocol)
├── GithubAuthService          (live conformer)
├── StubAuthService            (test/preview conformer)
├── GithubDeviceAuthenticator  (OAuth flow)
├── RefreshSettings            (value type)
├── RefreshService             (scheduler)
├── OctoidRefreshController    (GitHub poller)
└── LastEventStore             (protocol)

CoreUI
├── Engine                     (creates + wires all services)
├── GithubAuthService          (injects into Engine)
├── UserDefaultsLastEventStore (live LastEventStore)
├── ConnectionPrefsView        (reads authService from environment)
└── Settings.swift             (AppSettingKey definitions)
```
