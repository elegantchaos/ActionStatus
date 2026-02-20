# ActionStatus — AI Coding Agent Guide

This repository contains ActionStatus, an Xcode app for iOS, tvOS, and macOS, with shared logic in the local Swift package under `Dependencies/Core/`.

See https://actionstatus.elegantchaos.com/ for product context.

## Project-Specific Rules

### Core constraints

- Target iOS 26.0+ and/or macOS 26.0+.
- The codebase currently:
  - is Swift 5.x; migration to 6+ is desirable.
  - contains old UIKit/AppKit patterns; migration to cross-platform/SwiftUI is desirable.

### Code placement

- Keep shared logic in `Dependencies/Core/Sources/Core` when possible.
- Keep platform-specific behavior in `Sources/ActionStatusMobile`, `Sources/ActionStatusTV`, and `Sources/ActionStatusMac`.

### Required validation

- Run `Extras/Scripts/validate-changes` after code edits.

## Shared Baseline Guidance

These rules are refreshed from `~/.local/share/agents/COMMON.md` and related instruction modules.

### Principles

Apply these core principles:
- Keep It Simple
- Build What Is Needed
- Avoid Duplication Thoughtfully
- Single Source of Truth
- Make Invalid States Hard to Represent
- Explicit Dependencies
- Composition Over Inheritance
- Separate Commands From Queries
- Least Knowledge
- Concurrency by Design

### Scope and change strategy

- Prefer minimal, focused changes that solve the requested problem.
- Preserve existing architecture/style unless change is requested or clearly needed.
- Prefer fixing root causes over layered workarounds.

### Workflow expectations

1. Understand request boundaries.
2. Inspect relevant code/docs before editing.
3. Apply the smallest coherent change set.
4. Add/update tests for behavior changes where feasible.
5. Run relevant validation checks.
6. Report changes, validation status, and residual risks.

### Engineering, safety, and sources

- Prioritize correctness, clarity, and maintainability.
- Keep interfaces explicit and intentionally small.
- Avoid hidden coupling and surprising side effects.
- Do not add dependencies without clear justification.
- Do not perform destructive actions without explicit approval.
- Avoid unrelated refactors during focused tasks.
- If unexpected workspace changes appear, pause and confirm direction.
- Use trusted-source guidance for uncertain facts and external references.

## Detailed Guidelines

Managed copies live under `Extras/Documentation/Guidelines/`:
- Overview/index: `Extras/Documentation/Guidelines/README.md`
- Principles: `Extras/Documentation/Guidelines/Principles.md`
- Swift: `Extras/Documentation/Guidelines/Swift.md`
- SwiftUI: `Extras/Documentation/Guidelines/SwiftUI.md`
- Testing: `Extras/Documentation/Guidelines/Testing.md`
- Trusted sources: `Extras/Documentation/Guidelines/Trusted Sources.md`
- GitHub workflow: `Extras/Documentation/Guidelines/GitHub.md`

## Project references

- `README.md`
- `Settings.xcconfig`
- `ActionStatus.xcodeproj/project.pbxproj`

---

Refresh note: regenerate this file periodically using `~/.local/share/agents/REFRESH.md`, `~/.local/share/agents/COMMON.md`, and relevant files in `~/.local/share/agents/instructions/`.
