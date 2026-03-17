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
- Keep non-auth settings on `UserDefaults` / `@AppStorage` for SwiftUI views, while Core services observe relevant defaults changes without importing SwiftUI.
- Keep invalid stored credentials in Keychain but mark them invalid in published state so the UI can show the problem and allow retry or sign-out.
- Mirror refresh-controller injection with an auth override environment variable, for example `TEST_AUTH`, so app startup can substitute fake auth services for UI and integration testing.
- Introduce provider-level abstractions so auth and refresh are selected as a matched pair:
  - a provider identifier such as `github`, `gitlab`, or `codeberg`
  - provider-specific credentials and auth service implementations
  - provider-specific refresh controller factories
- Make provider pairing explicit in startup wiring so unsupported combinations cannot be created accidentally.
- Add a one-time migration path from legacy storage:
  - if the combined Keychain entry is absent
  - but legacy `githubUser`, `githubServer`, and token storage exist
  - assemble `GithubCredentials`
  - save the new single entry
  - clear legacy defaults/keychain data

## Provider and Injection Architecture

- Add a small provider abstraction at the service boundary rather than hard-coding GitHub into app startup.
- Define a provider selection type, for example `ForgeProvider`, with cases such as `github`, `gitlab`, and `codeberg`.
- Define a protocol for auth services, for example `AuthService`, that exposes:
  - published auth state
  - validated credentials if available
  - startup validation
  - sign-in completion
  - sign-out
- Define a protocol or factory for refresh creation that takes validated provider credentials and returns a provider-compatible refresh controller.
- Create a provider composition object or registry that owns the valid auth/refresh pairing for each provider.
  - GitHub maps to `GithubAuthService` plus `OctoidRefreshController`
  - future providers map to their own auth service plus their own refresh controller
  - unsupported pairings are unrepresentable in the registry
- Keep the first implementation GitHub-only, but shape the interfaces so adding a second provider is additive rather than a refactor.
- Add an auth override path in runtime metadata similar to `TEST_REFRESH`.
  - `TEST_AUTH` should allow values such as `signed-out`, `valid`, `invalid`, or `in-progress`
  - the injected auth double should publish stable canned states without touching Keychain or network
  - startup should compose the chosen auth service and refresh factory from runtime overrides before building the engine environment

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
- In Core services, observe `UserDefaults` changes for settings they care about using the existing notification/observation utilities instead of `@AppStorage`.
  - `RefreshService` should react to refresh-rate changes from defaults-backed configuration
  - auth services should not depend on `@AppStorage` or SwiftUI
- Keep auth persistence out of `UserDefaults`; only non-sensitive settings remain defaults-backed.
- Ensure injected test auth services and test refresh implementations are also observable so SwiftUI previews and runtime UI tests behave consistently with live services.

## Public API and Type Changes

- Add `GithubCredentials`
  - `login: String`
  - `server: String`
  - `token: String`
- Add a provider identifier, for example `ForgeProvider`
  - initial default is `github`
- Add `GithubAuthState`
  - explicit enum for signed-out, validating, signing-in, signed-in, invalid-stored-credentials, and error states
- Add `AuthService`
  - provider-agnostic protocol for observable sign-in state and auth operations
- Add `GithubAuthService`
  - exposes current auth state
  - exposes current validated credentials if available
  - owns startup validation, sign-in completion, and sign-out
- Update `RefreshService`
  - observe auth-service changes and coordinate refresh lifecycle from validated credentials
  - observe refresh-rate changes from defaults-backed configuration without using SwiftUI APIs
- Add a test auth implementation
  - driven from runtime environment for UI and integration testing
- Add a provider registry or factory layer
  - selects matched auth and refresh implementations for the active provider
- Keep SwiftUI-specific storage helpers out of Core services
  - UI continues using `@AppStorage`
  - Core continues using typed `UserDefaults` access and observation
- Remove legacy auth-related settings API
  - `githubUser`
  - `githubServer`
  - split token accessors tied to those defaults

## Test Plan

- `GithubCredentials` round-trips through the single Keychain entry.
- Legacy auth data migrates correctly into the new single-entry format and clears old storage.
- Startup with no credentials publishes signed-out state and does not start GitHub refresh.
- Startup with valid stored credentials publishes signed-in state and allows refresh to start.
- Startup with invalid stored credentials publishes invalid state and blocks refresh.
- Sign-in completion validates credentials before persisting them.
- Failed sign-in validation does not persist new credentials.
- Sign-out removes the Keychain entry, publishes signed-out state, and stops refresh.
- Preferences/auth UI reflects each auth state correctly, including validation-in-progress and invalid-credentials states.
- Views observing auth and refresh services update automatically when sign-in, sign-out, startup validation, or refresh-state transitions occur.
- Refresh-rate changes made through `@AppStorage` in UI propagate through defaults observation to `RefreshService` and update live refresh behavior.
- `TEST_AUTH` startup injection can force signed-out, valid, invalid, and in-progress auth states without real network or Keychain access.
- Auth doubles integrate cleanly with alternate refresh-controller injection so UI tests can exercise supported and unsupported startup configurations.
- Provider registry only constructs supported auth/refresh pairings and rejects unsupported combinations deterministically.

## Assumptions and Defaults

- Only one GitHub account/server is supported at a time, so a fixed Keychain key is correct for now.
- The first shipped provider remains GitHub, even though the architecture will introduce provider abstraction points now.
- Invalid stored credentials should remain stored until the user explicitly signs out or successfully signs in again.
- GitHub-dependent features should remain disabled until credentials are validated during the current startup/session.
- `OctoidRefreshController` should remain a refresh/polling component, not the owner of credential persistence and auth state.
- Test injection should follow the same runtime-environment pattern already used for refresh overrides, rather than a separate bespoke mechanism.
- SwiftUI observation is the preferred UI update mechanism; Core services may use Observation but should avoid direct SwiftUI storage/property-wrapper dependencies.
