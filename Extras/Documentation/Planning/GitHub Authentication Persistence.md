# GitHub Authentication Persistence Plan

## Summary

Redesign GitHub authentication persistence so the username, server, and token are stored together as a single `GithubCredentials` value in one Keychain entry. Validate stored credentials during app startup rather than only from Preferences, and publish explicit sign-in state so GitHub-dependent features can disable themselves when credentials are missing or invalid.

The recommended structure is to keep polling in `OctoidRefreshController`, but move credential storage, validation, and sign-in state into a dedicated auth service. `RefreshService` and the UI should consume that state rather than each performing their own credential checks.

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
- Keep invalid stored credentials in Keychain but mark them invalid in published state so the UI can show the problem and allow retry or sign-out.
- Add a one-time migration path from legacy storage:
  - if the combined Keychain entry is absent
  - but legacy `githubUser`, `githubServer`, and token storage exist
  - assemble `GithubCredentials`
  - save the new single entry
  - clear legacy defaults/keychain data

## Public API and Type Changes

- Add `GithubCredentials`
  - `login: String`
  - `server: String`
  - `token: String`
- Add `GithubAuthState`
  - explicit enum for signed-out, validating, signing-in, signed-in, invalid-stored-credentials, and error states
- Add `GithubAuthService`
  - exposes current auth state
  - exposes current validated credentials if available
  - owns startup validation, sign-in completion, and sign-out
- Update `RefreshService`
  - depend on auth state / validated credentials instead of directly reading token and server from configuration
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

## Assumptions and Defaults

- Only one GitHub account/server is supported at a time, so a fixed Keychain key is correct for now.
- Invalid stored credentials should remain stored until the user explicitly signs out or successfully signs in again.
- GitHub-dependent features should remain disabled until credentials are validated during the current startup/session.
- `OctoidRefreshController` should remain a refresh/polling component, not the owner of credential persistence and auth state.
