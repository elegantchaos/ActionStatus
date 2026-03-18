# Swift 6 Concurrency Warning Remediation Plan

## Summary

Eliminate all current Swift 6 concurrency warnings in `Dependencies/Core` by making Core model value types explicitly `Sendable` and removing `@Sendable` closure captures of non-Sendable UI classes in `Engine`.

## Warning Inventory (current)

1. `Dependencies/Core/Sources/CoreUI/Refreshing/GithubRefreshController.swift`
2. `Dependencies/Core/Sources/CoreUI/Engine.swift`

Observed warning classes:

1. `Repo` and `Repo.WorkflowSelection` are not `Sendable` but cross actor/`@Sendable` boundaries.
2. `Engine?` is captured inside `DispatchQueue.main.async` closures that are `@Sendable`.

## Chosen Strategy

1. Use the mixed strategy with a bias toward explicit `Sendable` for pure value types.
2. Keep UI/orchestration types (`Engine`) main-thread constrained and avoid capturing them in `@Sendable` queue closures.
3. Do not add `@unchecked Sendable` unless absolutely required; treat that as a fallback-only option.

## Public API / Type Changes

1. Update `Dependencies/Core/Sources/Core/Repo.swift`:
2. Change `Repo` to conform to `Sendable`.
3. Change `Repo.State` to conform to `Sendable`.
4. Change `Repo.WorkflowSelection` to conform to `Sendable`.
5. Keep data model semantics unchanged; this is a concurrency contract tightening, not behavior change.

No functional API behavior changes are expected in `CoreUI`; only concurrency-annotation and scheduling implementation updates.

## Implementation Plan

1. Update Core value types:
2. Add `Sendable` conformances in `Repo.swift` for `Repo`, `Repo.State`, and `Repo.WorkflowSelection`.
3. Compile and verify there are no new sendability diagnostics in `Repo.swift`.

4. Remove `Engine` `@Sendable` closure captures:
5. In `Engine.observeModelChanges()` and `Engine.observeSettingsChanges()`, replace `DispatchQueue.main.async { [weak self] ... }` with a main-thread scheduling mechanism that does not require `@Sendable` capture of `Engine?` (for example `OperationQueue.main.addOperation { [weak self] ... }`).
6. Preserve existing behavior: debounced model updates, settings save/update flow, and recursive re-observation.

7. Rebuild and verify warning closure:
8. Run `swift package clean && swift test` in `Dependencies/Core`.
9. Confirm no concurrency warnings remain for:
10. `GithubRefreshController.swift`
11. `Engine.swift`
12. If warnings remain, iterate only on annotation/scheduling boundaries, not functional refresh logic.

13. Add planning doc copy:
14. Create `Extras/Documentation/Planning/Swift 6 Concurrency Warnings Remediation.md`.
15. Include sections:
16. Warning inventory (file + warning type).
17. Strategy decision (why Sendable for model + main-thread scheduling for Engine).
18. Change list by file.
19. Validation commands and expected result.
20. Residual risks and follow-ups.

## Test Cases and Validation Scenarios

1. Build/test command:
2. `cd Dependencies/Core && swift package clean && swift test`
3. Expected:
4. Zero Swift 6 concurrency warnings for `Engine.swift` and `GithubRefreshController.swift`.
5. Existing non-concurrency warnings may remain and should be documented separately.

6. Behavioral smoke checks (manual):
7. Launch macOS debug build from Xcode.
8. Verify model changes still persist and trigger UI updates.
9. Verify settings changes still trigger save + refresh update behavior.

## Acceptance Criteria

1. No `Sendable`/`@Sendable`/actor-isolation warnings remain in the current Core warning set.
2. No behavior regression in model/state observation loops.
3. Planning document exists at `Extras/Documentation/Planning/Swift 6 Concurrency Warnings Remediation.md` and reflects final implemented changes.

## Assumptions and Defaults

1. Assumption: current warning set is limited to `Repo` sendability and `Engine` closure captures in Core.
2. Default: use explicit `Sendable` on value-model types rather than `@unchecked Sendable`.
3. Default: avoid broad actor-annotation refactors (`@MainActor` on entire `Engine`) unless needed after initial pass.
4. This plan is decision-complete and ready for implementation.
