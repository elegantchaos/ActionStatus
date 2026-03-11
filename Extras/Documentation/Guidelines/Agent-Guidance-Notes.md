# Agent Guidance Notes

## Regenerated files

- `AGENTS.md`
- `Extras/Documentation/Guidelines/README.md`
- `Extras/Documentation/Guidelines/Principles.md`
- `Extras/Documentation/Guidelines/Testing.md`
- `Extras/Documentation/Guidelines/Trusted Sources.md`
- `Extras/Documentation/Guidelines/Good Code.md`
- `Extras/Documentation/Guidelines/Swift.md`
- `Extras/Documentation/Guidelines/SwiftUI.md`
- `Extras/Documentation/Guidelines/GitHub.md`

## Included modules

- `instructions/COMMON.md` (compacted into `AGENTS.md` Standard Rules)
- `instructions/README.md`
- `instructions/Principles.md`
- `instructions/Testing.md`
- `instructions/Trusted Sources.md`
- `instructions/Good Code.md`
- `instructions/languages/Swift.md`
- `instructions/technologies/SwiftUI.md`
- `instructions/services/GitHub.md`

## Excluded modules

- `instructions/languages/JavaScript.md` (no JavaScript stack evidence)
- `instructions/languages/Python.md` (no Python stack evidence)

## Detected stack assumptions

- Swift codebase (`.swift` files across `Sources/`, `Dependencies/`, and `Tests/`)
- Swift Package Manager usage (`Dependencies/*/Package.swift`)
- Xcode app/workspace (`ActionStatus.xcodeproj`, `ActionStatus.xcworkspace`)
- SwiftUI usage (`Dependencies/Core/Sources/CoreUI/Views/*.swift`, app entry points under `Sources/ActionStatus*`)
- GitHub-centric workflows and integrations (project naming, docs, and `gh` workflow requirements)

## Unresolved local-vs-shared instruction conflicts

- None found. Local constraints (platform targets, code placement, required validation script) were preserved.
