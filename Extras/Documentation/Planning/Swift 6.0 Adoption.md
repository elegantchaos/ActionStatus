# Swift 6.0 Adoption Plan

This plan tracks migration from legacy Swift 5-era patterns to Swift 6-friendly architecture and compiler settings, while keeping iOS, macOS, and tvOS builds stable.

## Status Snapshot

Completed foundations:
- UI refresh phases completed.
- Removed `SwiftUIExtensions`, `SheetController`, and `ApplicationExtensions` from active app code paths.
- `Dependencies/Core/Package.swift` now uses `swift-tools-version: 6.0`.

Current state:
- Core package currently builds in Swift language mode v5 (`swiftLanguageModes: [.v5]`).
- Strict Swift 6 concurrency immediately surfaces a broad error set (global `Channel` sendability, actor isolation, preview/test call sites, and cross-module shared singletons).

## Target Architecture

- Rename current `Core` module/product to `CoreUI`.
- Introduce a new `Core` module/product for non-UI domain/runtime logic.
- Enable strict concurrency in `Core` first.
- Keep `CoreUI` as migration buffer until UI/state lifetimes are fully actor-safe.

## Phase A: Module Split (CoreUI/Core)

Goals:
- Establish a clean boundary between UI and non-UI code.

Actions:
1. Rename current package target/product `Core` to `CoreUI`.
2. Add new target/product `Core`.
3. Update app targets to import `CoreUI`.
4. Wire `CoreUI` to depend on `Core`.

Initial move candidates into `Core`:
- `Repo`, `RepoSettings`, `Platform`, `Compiler`, `WorkflowSettings`, generator types.
- Refreshing protocol-level logic that does not require SwiftUI/UI runtime.

Exit criteria:
- App compiles against `CoreUI`.
- `Core` compiles as a separate target with no SwiftUI dependency.

## Phase B: Concurrency Baseline in Core

Goals:
- Turn on strict concurrency for `Core` only.

Actions:
1. Set strict concurrency flags for `Core` target.
2. Address sendability for global/shared values (especially logger/channel wrappers).
3. Remove unsafe shared mutable global state from domain/runtime paths.
4. Add actor boundaries where needed (`actor`, `Sendable`, isolated services).

Exit criteria:
- `Core` builds under strict concurrency with no warnings/errors.

## Phase C: CoreUI Concurrency Hardening

Goals:
- Migrate UI and app-lifecycle code to actor-safe boundaries.

Actions:
1. Isolate UI state owners (`ViewContext`, app coordinator-like types) to main actor where appropriate.
2. Remove implicit shared singleton mutation patterns or guard them behind actor boundaries.
3. Update previews/tests for actor-isolated initializers and APIs.

Exit criteria:
- `CoreUI` is strict-concurrency clean or has a minimal, documented exceptions list.

## Phase D: Language Mode Rollout

Goals:
- Run Swift 6 language mode project-wide.

Actions:
1. Switch `Core` to Swift 6 language mode.
2. Switch `CoreUI` to Swift 6 language mode once concurrency-clean.
3. Update project build settings for all app targets.

Exit criteria:
- iOS/macOS/tvOS builds + tests pass in Swift 6 mode.

## Guidance from Stack Project

Observed Stack settings:
- `SWIFT_VERSION = 6.0`
- `SWIFT_APPROACHABLE_CONCURRENCY = YES`
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` (applied in key targets)
- `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES`

Recommendation for ActionStatus:
- Adopt this direction eventually, but incrementally.
- Do not enable `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` globally yet.
- Enable strictness first in new non-UI `Core` target, then converge `CoreUI`.

## Validation Rule

After every migration slice:
- Run `Extras/Scripts/validate-changes`.
- Keep commits small and phase-scoped.
