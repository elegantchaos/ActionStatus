# Principles

These principles are intended for anyone contributing code to ActionStatus (humans and coding agents).

This file does not override `AGENTS.md`; it explains the “why” behind coding guidance so tradeoffs stay consistent when the codebase does not provide an obvious answer.

## How to use this

- Apply these principles as heuristics, not strict rules.
- When principles conflict, prefer the principle that best reduces user-visible risk and long-term maintenance cost.
- If a change increases complexity, be explicit about why the complexity is necessary.

## Principles

### Occam’s Razor / KISS

Prefer the simplest implementation that satisfies the requirements.

Signals you’re violating it:
- You’re adding new abstractions “just in case”.
- You’re creating generic infrastructure to solve a one-off.

Good ActionStatus examples:
- Keep feature wiring local until it repeats.
- Don’t introduce a coordinator or router layer unless navigation/presentation requirements demand it.

### YAGNI

Don’t build optionality or extensibility until you have a concrete need.

Use it to decide:
- Whether to add a protocol now vs. wait.
- Whether a type should be `public` or remain `internal`.

### DRY (balanced with clarity)

Avoid duplication when it reduces bugs and maintenance.

Practical guidance:
- Deduplicate logic (behavior) sooner than you deduplicate presentation.
- Avoid “DRYing” unrelated code into an abstraction that hides intent.
- In tests, deduplicate expensive setup and repeated literals (but keep assertions explicit).

### Single Source of Truth

Keep authoritative state in one place; compute derived state from it.

In SwiftUI:
- Prefer storing the minimal mutable state in a model/view model.
- Keep formatted strings and “isEnabled” style values derived.

### Make Invalid States Unrepresentable

Use the type system to prevent illegal states.

Techniques:
- Use enums for state machines.
- Use typed identifiers (enums, wrappers) instead of raw strings.
- Use non-optional properties when a value must exist.

### SOLID (focus: SRP + DIP)

- SRP (Single Responsibility Principle): types should have one reason to change.
- DIP (Dependency Inversion Principle): high-level logic depends on abstractions, not concrete details.

In this repo:
- View models depend on protocols for services (store, persistence, clock, etc.) when it improves testability.
- UI-facing types remain `@MainActor` and avoid I/O directly.

### Dependency Injection

Prefer explicit dependencies over hidden globals.

Practical defaults:
- Constructor injection for view models/services.
- Protocol boundaries around I/O (networking, StoreKit, filesystem, time).
- Avoid singletons unless the codebase already standardizes on one.

### Composition over Inheritance

Prefer composing small types and protocol conformances over deep class hierarchies.

In Swift:
- Prefer protocols + extensions for behavior.
- Prefer small helper types over base classes.

### Command–Query Separation

Separate “doing” from “calculating”.

Guidance:
- A method that mutates state should return `Void` (or a narrow result) rather than also returning complex derived values.
- Use separate computed properties/functions for derived data.

### Principle of Least Knowledge (Law of Demeter)

Minimize how much one part of the code knows about another.

In practice:
- Pass value types across module boundaries.
- Avoid leaking framework types (like StoreKit models) into view models/views unless the boundary requires it.

### Pit of Success APIs

Design APIs so the easiest path is the correct one.

Examples:
- Strongly typed product IDs.
- Wrapper types that ensure verification ordering or prevent forgetting required steps.

### Concurrency-by-Design

Be explicit about concurrency boundaries.

Guidance:
- UI-facing types: `@MainActor`.
- Shared mutable state: an actor.
- Avoid shared global mutable state.
- Prefer Swift concurrency primitives over GCD.

## Decision heuristics (when unsure)

- Prefer correctness and user safety over micro-optimizations.
- Prefer a smaller surface area (`internal` by default; keep `public` APIs intentional).
- Prefer local changes over cross-cutting refactors.
- Prefer patterns already used in the codebase.

## Writing guidance (for agent outputs)

- Explain tradeoffs briefly when changing architecture.
- Keep diffs small and focused.
- If you introduce a new abstraction, point to the specific duplication/bug risk it addresses.
