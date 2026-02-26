# ActionStatus — AI Coding Agent Guide

This repository contains ActionStatus, an Xcode app for iOS, tvOS, and macOS, with shared logic in the local Swift package under `Dependencies/Core/`.

See <https://actionstatus.elegantchaos.com/> for product context.

## Project Specific Rules

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

### Project references

- `README.md`
- `Settings.xcconfig`
- `ActionStatus.xcodeproj/project.pbxproj`
- Local guideline docs: `Extras/Documentation/Guidelines/README.md`

## Standard Rules

### Baseline methodology

- Prefer red/green TDD unless impractical; otherwise follow the testing workflow and report gaps.
- Always write good code and keep behavior, tests, and docs aligned.
- Apply KISS, YAGNI, DRY thoughtfully, explicit dependencies, composition over inheritance, command-query separation, least knowledge, structured concurrency, design by contract, and idempotency.

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

- Follow project Swift/platform targets and prefer migration-friendly modern Swift patterns.
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
