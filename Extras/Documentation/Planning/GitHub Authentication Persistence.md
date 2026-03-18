# GitHub Authentication Persistence Plan

## Summary

Redesign GitHub authentication persistence so the username, server, and token are stored together as a single `GithubCredentials` value in one Keychain entry. Validate stored credentials during app startup rather than only from Preferences, and publish explicit sign-in state so GitHub-dependent features can disable themselves when credentials are missing or invalid.

The recommended structure is to keep polling in `OctoidRefreshController`, but move credential storage, validation, and sign-in state into a dedicated auth service. `RefreshService` and the UI should consume that state rather than each performing their own credential checks.

The design should also support:
- startup injection of alternate auth services, matching the existing `TEST_REFRESH` override pattern used for refresh controllers
- a future with multiple providers such as GitHub, GitLab, and Codeberg, where valid auth and refresh pairings are explicit rather than accidental
- SwiftUI observation as the primary UI update mechanism, while keeping Core services free of SwiftUI-only APIs such as `@AppStorage`

## Key Changes

- Add a `GithubCredentials` value type with `login`, `server`, and `token`.
- Persist `GithubCredentials` as one fixed-key Keychain payload because only one signed-in server/account is supported at a time.
- Remove `githubUser` and `githubServer` from `UserDefaults` and remove auth persistence responsibilities from `StoredRefreshConfiguration`.
- Introduce a dedicated observable auth service, for example `GithubAuthService`, responsible for:
  - loading stored credentials from Keychain
  - validating stored credentials at startup
  - validating new credentials before persisting them
  - clearing credentials on sign-out
  - publishing current sign-in state
- Publish an explicit auth state enum rather than a boolean, covering:
  - signed out
  - validating stored credentials
  - signing in
  - signed in with validated credentials
  - stored credentials invalid
  - sign-in failed
- Update startup flow so engine startup triggers auth validation before GitHub refresh starts.
- Update `RefreshService` so GitHub refresh only runs when auth state provides validated credentials.
- Keep `OctoidRefreshController` focused on repository refresh using already-validated credentials, rather than giving it ownership of Keychain I/O and auth lifecycle.
- Update the sign-in/sign-out UI so it owns only transient device-flow UI state, then hands completed `GithubCredentials` to the auth service.
- Make auth and refresh services observable so SwiftUI views can observe them directly and refresh automatically when auth state or refresh state changes.
- Push sign-in and sign-out mutations back through the auth service so one observable source of truth drives all interested UI.
- Coordinate auth and refresh at the app/service layer rather than having `OctoidRefreshController` own auth observation directly.
- Remove the `RefreshConfiguration` class hierarchy (`RefreshConfiguration` + `StoredRefreshConfiguration` as subclass). Replace with a `RefreshSettings` value type pushed from CoreUI. `StoredRefreshConfiguration` is dissolved; credential storage moves to `GithubAuthService` and refresh-rate wiring moves to Engine.
- Remove `GithubAuthenticatedUser`. `GithubDeviceAuthenticator.pollForUser` returns `GithubCredentials` directly.
- Remove `GithubAuthUIState` and `GithubAuthHealth` from the view layer. Both are replaced by the single `GithubAuthState` published by `GithubAuthService`. `ConnectionPrefsView` derives all display state from that one enum.
- Make `GithubDeviceAuthorization` internal to Core — it is only an intermediate value used during the device flow and does not need to be part of the public API.
- Defer multi-provider abstractions (`ForgeProvider`, provider registry, provider factory) until a second provider is actually being added. The interfaces should be shaped to accommodate extension, but no registry or factory layer is built now.
- Keep invalid stored credentials in Keychain but mark them invalid in published state so the UI can show the problem and allow retry or sign-out.
- Mirror refresh-controller injection with an auth override environment variable, for example `TEST_AUTH`, so app startup can substitute fake auth services for UI and integration testing.
- Add a one-time migration path from legacy storage:
  - if the combined Keychain entry is absent
  - but legacy `githubUser`, `githubServer`, and token storage exist
  - assemble `GithubCredentials`
  - save the new single entry
  - clear legacy defaults/keychain data

## Injection Architecture

- Define a minimal `AuthService` protocol that exposes:
  - observable auth state
  - validated credentials if available
  - startup validation
  - sign-in completion
  - sign-out
- The protocol exists primarily to allow test doubles to be injected without touching Keychain or network. Do not add any surface area beyond what the protocol needs.
- `GithubAuthService` is the single concrete implementation for the current GitHub-only codebase.
- `RefreshService` depends on `AuthService` (the protocol) rather than `GithubAuthService` directly, so it remains testable and provider-agnostic without requiring a full provider registry.
- Add an auth override path in runtime metadata similar to `TEST_REFRESH`.
  - `TEST_AUTH` should allow values such as `signed-out`, `valid`, `invalid`, or `in-progress`
  - the injected auth double should publish stable canned states without touching Keychain or network
  - startup should compose the chosen auth service from runtime overrides before building the engine environment

## Observation and Settings Integration

- Make `GithubAuthService` and `RefreshService` `@Observable` so SwiftUI views can depend on them through environment injection and update automatically when state changes.
- Treat the auth service as the single source of truth for auth state and current validated credentials.
  - sign-in success updates auth service state
  - sign-out updates auth service state
  - startup validation updates auth service state
  - all observing views refresh from those mutations
- Keep orchestration between auth and refresh in `RefreshService` or engine-level coordination, not inside `OctoidRefreshController`.
  - preferred design: `RefreshService` observes `AuthService` state and recreates/pauses/resumes refresh as auth state changes
  - `OctoidRefreshController` remains a passive refresh implementation created from validated credentials
- Keep refresh state observable as well, so UI that reflects paused/running/testing states continues to update automatically.
- Continue using `@AppStorage` only in SwiftUI-facing code for non-auth settings such as refresh rate and display preferences.
- **Core services must have no UserDefaults dependency of any kind.** No direct `UserDefaults` reads, no `UserDefaults.didChangeNotification` observation, and no `@AppStorage` property wrappers. All settings values are received as pushed value types from CoreUI.
- CoreUI (Engine) is the sole point that observes `UserDefaults`/`@AppStorage` changes. When a relevant setting changes, Engine pushes a concrete value type to the affected service and pauses or restarts the service where necessary.
  - When `refreshInterval` changes, Engine calls a dedicated update method on `RefreshService` with the new rate, which pauses and resumes at the new interval.
  - When `sortMode` changes, Engine pushes the new `SortMode` value to `StatusService`, which re-sorts without reading defaults itself.
  - When auth credentials change, `GithubAuthService` publishes new auth state; Engine or `RefreshService` observes that state to coordinate refresh lifecycle.
- Replace the `RefreshConfiguration` class hierarchy with a `RefreshSettings` value type. `RefreshService` receives a `RefreshSettings` at init and accepts updates via an explicit `apply(_ settings: RefreshSettings)` method. The method pauses, replaces the settings, and restarts refresh when the values that affect the active controller change.
- Remove `StoredRefreshConfiguration` as a `RefreshConfiguration` subclass. It becomes a pure CoreUI credential-management utility used only by `GithubAuthService` and `ConnectionPrefsView`.
- `OctoidRefreshController` must not read or write `UserDefaults` directly. Per-repo `lastEvent` timestamps are persisted through an injected `LastEventStore` protocol defined in Core. CoreUI provides a `UserDefaultsLastEventStore` implementation. Tests supply an in-memory double.
- `StatusService` removes its `UserDefaults.didChangeNotification` observer and its direct `UserDefaults` read of `sortMode`. Engine initialises `StatusService` with the current sort mode and pushes new values via `StatusService.apply(sortMode:)` whenever the setting changes.
- Keep auth persistence out of `UserDefaults`; only non-sensitive settings remain defaults-backed.
- Ensure injected test auth services and test refresh implementations are also observable so SwiftUI previews and runtime UI tests behave consistently with live services.

## Public API and Type Changes

**Remove** (type consolidation):
- `GithubAuthenticatedUser` — replaced by `GithubCredentials`
- `GithubAuthUIState` — replaced by `GithubAuthState`
- `GithubAuthHealth` — replaced by `GithubAuthState`
- `SettingsServiceError` — replaced by `GithubAuthServiceError` or similar
- `RefreshConfiguration` (abstract class) — replaced by `RefreshSettings` value type
- `StoredRefreshConfiguration` (subclass) — dissolved; responsibilities split across `GithubAuthService` and Engine

**Add**:
- `GithubCredentials` — `login: String`, `server: String`, `token: String`
- `GithubAuthState` — explicit enum: `.signedOut`, `.validating(GithubCredentials)`, `.signingIn`, `.awaitingApproval(userCode: String, url: URL)`, `.signedIn(GithubCredentials)`, `.invalidCredentials(GithubCredentials)`, `.failed(String)`
- `AuthService` — minimal protocol for observable auth state and operations; exists for test injection
- `GithubAuthService` — observable, owns startup validation, sign-in completion, sign-out, and Keychain persistence
- `RefreshSettings` — `token: String`, `server: String`, `interval: RefreshRate`; pushed from Engine to `RefreshService`
- `LastEventStore` — protocol in Core: `func read(key: String) -> Date` / `func write(_ date: Date, key: String)`
- `UserDefaultsLastEventStore` — in CoreUI; `UserDefaults`-backed implementation of `LastEventStore`
- `StubAuthService` — canned-state auth double driven by `TEST_AUTH` runtime environment variable

**Update**:
- `GithubDeviceAuthenticator.pollForUser` — returns `GithubCredentials` instead of `GithubAuthenticatedUser`
- `GithubDeviceAuthorization` — make internal to Core (used only during the device flow)
- `GithubDeviceAuthError` — keep as thrown error from authenticator; may absorb `SettingsServiceError.missingGithubAccount` as a case
- `RefreshService` — init receives `AuthService` and initial `RefreshSettings`; adds `apply(_ settings: RefreshSettings)` for Engine-pushed rate changes; observes `AuthService` state to coordinate refresh lifecycle
- `OctoidRefreshController` — init receives a `LastEventStore` for per-repo timestamp persistence; no direct `UserDefaults` access
- `StatusService` — remove `UserDefaults.didChangeNotification` observation and direct `sortMode` read; add `apply(sortMode: SortMode)` method; Engine pushes current sort mode at init and on change
- `SettingsService` — remains lightweight: `isEditing`, `repoNavigationMode(for:)`, navigation mode keys only

**Remove legacy API**:
- `AppSettingKey.githubUser`
- `AppSettingKey.githubServer`
- token accessors on `StoredRefreshConfiguration`

## Test Plan

- `GithubCredentials` round-trips through the single Keychain entry.
- Legacy auth data migrates correctly into the new single-entry format and clears old storage.
- Startup with no credentials publishes `.signedOut` and does not start GitHub refresh.
- Startup with valid stored credentials publishes `.signedIn` and allows refresh to start.
- Startup with invalid stored credentials publishes `.invalidCredentials` and blocks refresh.
- Sign-in completion validates credentials before persisting them.
- Failed sign-in validation does not persist new credentials.
- Sign-out removes the Keychain entry, publishes `.signedOut`, and stops refresh.
- `GithubAuthState` transitions drive `ConnectionPrefsView` display correctly for all states.
- Views observing `GithubAuthService` and `RefreshService` update automatically on state transitions.
- Refresh-rate changes pushed from Engine via `apply(_ settings:)` update live refresh behavior without `RefreshService` reading UserDefaults.
- Sort-mode changes pushed from Engine via `apply(sortMode:)` update `StatusService` without it reading UserDefaults.
- `TEST_AUTH` startup injection forces signed-out, valid, invalid, and in-progress states without real network or Keychain access.
- `LastEventStore` injection allows `OctoidRefreshController` to be tested with an in-memory store, verifying save/restore behaviour without `UserDefaults`.
- `GithubDeviceAuthenticatorTests` converted from XCTest to Swift Testing.

## Assumptions and Defaults

- Only one GitHub account/server is supported at a time, so a fixed Keychain key is correct for now.
- The first shipped provider remains GitHub. Multi-provider abstractions (`ForgeProvider`, provider registry, factory) are deferred until a second provider is actively being added; they are not built speculatively.
- Invalid stored credentials should remain stored until the user explicitly signs out or successfully signs in again.
- GitHub-dependent features should remain disabled until credentials are validated during the current startup/session.
- `OctoidRefreshController` should remain a refresh/polling component, not the owner of credential persistence and auth state.
- Test injection follows the same runtime-environment pattern already used for refresh overrides (`TEST_REFRESH`), not a bespoke mechanism.
- SwiftUI observation is the preferred UI update mechanism; Core services use `@Observable` but avoid direct SwiftUI storage/property-wrapper dependencies.
- `RefreshService` observes `AuthService` state directly via `@Observable` tracking (service-to-service, both in Core). This is distinct from UserDefaults-backed settings, which are always pushed from Engine.
