# ActionStatus — AI coding agent guide (Swift / SwiftUI)

This repository contains ActionStatus, an Xcode app for iOS, tvOS, and macOS, with shared logic in the local Swift package under `Dependencies/Core/`.

See https://actionstatus.elegantchaos.com/ for product context.

## Agent workflow (fast path)

1. Understand the request and scope.
2. Prefer minimal, focused changes in the correct package.
3. Add/update tests for behavior changes.
4. Run `Extras/Scripts/validate-changes`.
5. Summarize what changed, why, and any risks.

## Core constraints

- Target iOS 26.0+ and/or macOS 26.0+.
- The codebase is currently Swift 5.x.
- Changes should be made with migration to Swift 6 in mind (prefer modern concurrency-safe patterns where practical).
- Prefer cross-platform and SwiftUI solutions when available.
- UIKit/AppKit are acceptable when required for platform behavior (for example Catalyst integration).
- Do not add third-party frameworks without approval.
- Never add secrets (API keys, tokens) to the repo.

## Code placement

- Keep shared logic in `Dependencies/Core/Sources/Core` when possible.
- Keep platform-specific behavior in `Sources/ActionStatusMobile`, `Sources/ActionStatusTV`, and `Sources/ActionStatusMac`.
- Prefer existing architecture and file boundaries unless there is a clear reason not to.

## Required validation

- Run `Extras/Scripts/validate-changes` after edits.
- Use `Extras/Scripts/validate-target <target-name>` for quick target checks.

## Detailed guidelines

- Overview/index: `Extras/Documentation/Guidelines/README.md`
- Principles and tradeoff heuristics: `Extras/Documentation/Guidelines/Principles.md`
- Swift language and file/type layout rules: `Extras/Documentation/Guidelines/Swift.md`
- SwiftUI-specific conventions: `Extras/Documentation/Guidelines/SwiftUI.md`
- Testing expectations: `Extras/Documentation/Guidelines/Testing.md`
- Research references and source-of-truth policy: `Extras/Documentation/Guidelines/Trusted Sources.md`

## Project references

- `README.md`
- `Settings.xcconfig`
- `ActionStatus.xcodeproj/project.pbxproj`
