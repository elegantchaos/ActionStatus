# Octoid Modernisation Plan

This plan tracks modernization of Octoid usage and integration, with emphasis on async/await and Swift concurrency.

## Context

- ActionStatus now includes a local workspace checkout of `Octoid` (`../Octoid`).
- ActionStatus currently has custom integration logic in:
  - `OctoidRefreshController`
  - `RepoPollingSession`
  - `WorkflowRunsProcessor`
  - `EventsProcessor`

These should be re-evaluated once Octoid provides modern async APIs.

## Objectives

1. Modernize Octoid networking APIs to async/await.
2. Reduce adapter/processor glue code in ActionStatus where Octoid can provide equivalent behavior.
3. Remove local overrides/subclasses that no longer add value.
4. Improve cancellation and structured concurrency behavior.

## Phase 1: API Inventory

Actions:
1. Audit current Octoid public API surfaces used by ActionStatus.
2. Map callback/session-style entry points to async equivalents.
3. Identify ActionStatus-specific behavior that must remain local (state mapping, retry policy, UI update policy).

Deliverable:
- A compatibility matrix: old API -> async replacement -> migration owner.

## Phase 2: Add Async Surfaces in Octoid

Actions:
1. Introduce async request APIs for workflow runs and events retrieval.
2. Implement structured cancellation (Task cancellation propagation).
3. Add clear error taxonomy for retryable vs non-retryable failures.

Deliverable:
- Octoid builds with async APIs and tests for cancellation/retry semantics.

## Phase 3: Migrate ActionStatus Integration

Actions:
1. Replace `RepoPollingSession` session orchestration with task-based async flow.
2. Collapse `WorkflowRunsProcessor` / `EventsProcessor` where Octoid can return typed results directly.
3. Keep only minimal mapping layer from Octoid responses -> `Repo.State` and status counts.

Deliverable:
- ActionStatus refresh path no longer depends on callback/session orchestration primitives.

## Phase 4: Remove Obsolete Local Overrides

Actions:
1. Remove local subclasses/adapters that duplicate behavior now native in Octoid.
2. Delete dead code and update package dependencies if no longer needed.
3. Retain extension points only where product-specific behavior is still intentional.

Deliverable:
- Cleaner ActionStatus refresh stack with smaller maintenance surface.

## Phase 5: Concurrency Hardening

Actions:
1. Ensure Octoid-facing models and errors are `Sendable` where appropriate.
2. Validate main-actor handoff for UI updates happens only at UI boundary.
3. Add tests for race conditions and cancellation under rapid refresh cycles.

Deliverable:
- Stable async refresh behavior with clear actor boundaries.

## Coordination with Swift 6 Adoption

- Prefer landing Octoid async APIs before strict concurrency in ActionStatus refresh code.
- Sequence recommendation:
  1. Swift 6 plan Phase A (Core/CoreUI split)
  2. Octoid async API introduction
  3. ActionStatus refresh migration
  4. Strict concurrency enablement in non-UI Core

## Validation Rule

After each migration slice:
- Run `Extras/Scripts/validate-changes`.
- Include targeted refresh tests (successful fetch, auth error, network timeout, cancellation).
