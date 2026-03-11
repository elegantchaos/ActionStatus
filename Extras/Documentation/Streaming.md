# Streaming Architecture

## Overview

ActionStatus now uses a stream-based polling model for GitHub updates.

The stack is intentionally layered:

1. `JSONSession` handles authenticated HTTP transport and low-level polling streams.
2. `Octoid` maps GitHub endpoints/payloads and vends repository update streams.
3. `ActionStatus` consumes those streams and updates app state/UI.

This design keeps transport concerns separate from GitHub domain logic and UI state management.

## Data Flow

For each tracked repository:

1. ActionStatus creates a `JSONSession.Session` and a repo stream consumer task.
2. ActionStatus asks Octoid for `Session.repositoryUpdates(...)`.
3. Octoid starts endpoint polling streams (events, workflows, workflow runs) using `JSONSession.pollData(...)`.
4. JSONSession emits response/error events as an `AsyncStream`.
5. Octoid decodes payloads and emits typed `RepositoryUpdate` values.
6. ActionStatus consumes updates and translates them into `Repo.State` changes.

## JSONSession Role

JSONSession is the transport layer.

It provides:

- one-shot request APIs (`request`, `data`)
- stream polling API (`pollData`) with cancellation tied to stream termination
- resource path abstraction (`ResourceResolver`)

JSONSession does not model GitHub-specific state or app-level semantics.

## Octoid Role

Octoid is the GitHub domain layer.

It provides:

- endpoint resources (`EventsResource`, `WorkflowsResource`, `WorkflowResource`)
- GitHub payload models (`Events`, `Workflows`, `WorkflowRuns`, etc.)
- stream composition via `repositoryUpdates(for:configuration:)`

Octoid decodes raw transport events into domain updates:

- `.events(...)`
- `.workflows(...)`
- `.workflowRuns(...)`
- `.message(...)`
- `.transportError(...)`

It also coordinates workflow-run polling targets based on discovered workflows.

## ActionStatus Role

ActionStatus is the orchestration and presentation layer.

`OctoidRefreshController` consumes repo update streams and:

- merges discovered workflows into the model
- tracks workflow run states for enabled workflows
- aggregates workflow states into a single repo status
- applies updates to the app model on the main actor

ActionStatus owns UI behavior, persistence decisions (for example last event timestamps), and user-facing policy.

## Why This Design

Key benefits of streaming over callback/timer-heavy polling:

- clearer ownership of cancellation and task lifetime
- better composability with structured concurrency
- fewer shared mutable polling internals
- easier testing at each layer (transport, domain, app)

The result is a pipeline where each layer has one job and communicates through typed async streams.
