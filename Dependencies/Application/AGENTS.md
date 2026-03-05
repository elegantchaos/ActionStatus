# ActionStatus Application Package — AI Coding Agent Guide

This repository contains the `Application` Swift package used by ActionStatus for shared app-layer logic and test utilities.

## Project Specific Rules

### Core constraints

- Target iOS 26.0+, macOS 26.0+, and tvOS 26.0+.
- Follow project Swift/tooling constraints from `Package.swift` (currently Swift tools 6.2 with strict concurrency-related settings).
- Keep shared logic inside this package and avoid duplicating logic across app targets.

### Code placement

- Keep primary package code in `Sources/Application/`.
- Keep package tests in `Tests/ApplicationTests/`.
- Treat `Extras/TestApplication/` as support/demo infrastructure, not a place for production shared logic.

### Project references

- `Package.swift`
- `Sources/Application/`
- `Tests/ApplicationTests/`
- `Extras/Documentation/Guidelines/README.md` (if present)

Reference guideline docs in `Extras/Documentation/Guidelines/` for detailed instructions.

## Standard Rules

### Baseline methodology

- Use red/green TDD for non-UI code; create previews for UI code where relevant.
- Always write good code and keep behavior, tests, and docs aligned.
- Apply KISS, YAGNI, DRY, explicit dependencies, composition over inheritance, command-query separation, least knowledge, structured concurrency, design by contract, and idempotency.

Reference:
- `Extras/Documentation/Guidelines/Principles.md`
- `Extras/Documentation/Guidelines/Good Code.md`

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

Reference:
- `Extras/Documentation/Guidelines/Testing.md`

### Engineering, safety, and source quality

- Prioritize correctness, clarity, and maintainability.
- Keep interfaces explicit and intentionally small.
- Avoid hidden coupling and surprising side effects.
- Do not add dependencies without clear justification.
- Never expose or commit credentials/secrets.
- Do not perform destructive actions without explicit approval.
- Avoid unrelated refactors during focused tasks.
- If unexpected workspace changes appear, pause and confirm direction.
- Use trusted, primary sources for uncertain facts and external references.

Reference:
- `Extras/Documentation/Guidelines/Trusted Sources.md`

### Swift and SwiftUI expectations

- Follow package Swift/platform targets and prefer modern migration-friendly Swift patterns.
- Keep Swift files focused, visibility tight, and concurrency ownership explicit.
- Prefer structured concurrency and clear state modeling.
- Keep SwiftUI state intentional, views composable, and platform specialization isolated.

Reference:
- `Extras/Documentation/Guidelines/Swift.md`
- `Extras/Documentation/Guidelines/SwiftUI.md`

### GitHub workflow safety

- For `gh` commands with Markdown bodies, use `--body-file` rather than inline `--body`.
- Keep PR summaries factual, scoped to the diff, and include validation/gaps.

Reference:
- `Extras/Documentation/Guidelines/GitHub.md`

### Code comments

- Add compact documentation comments for each type, method/function, and member/property describing purpose.
- Comments should add intent/context, not restate names.
- For the primary type in a source file, add a top-level documentation comment with design/implementation detail.
- Keep inline comments sparse and focused on subtle logic or constraints.

To refresh this file, use the refresh-agents skill.
