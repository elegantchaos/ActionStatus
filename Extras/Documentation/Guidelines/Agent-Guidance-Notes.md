# Agent Guidance Notes

## Regenerated files

- `AGENTS.md`
- `Extras/Documentation/Guidelines/Principles.md`
- `Extras/Documentation/Guidelines/Testing.md`
- `Extras/Documentation/Guidelines/Trusted Sources.md`
- `Extras/Documentation/Guidelines/Good Code.md`
- `Extras/Documentation/Guidelines/Swift.md`
- `Extras/Documentation/Guidelines/SwiftUI.md`
- `Extras/Documentation/Guidelines/GitHub.md`

## Included modules

- `instructions/COMMON.md` (compacted into `AGENTS.md` Standard Rules)
- `instructions/Principles.md`
- `instructions/Testing.md`
- `instructions/Trusted Sources.md`
- `instructions/Good Code.md`
- `instructions/languages/Swift.md`
- `instructions/technologies/SwiftUI.md`
- `instructions/services/GitHub.md`

## Excluded modules

- `instructions/languages/JavaScript.md` (no JS stack evidence)
- `instructions/languages/Python.md` (no Python stack evidence)

## Detected stack assumptions

- Swift codebase (`.swift` sources)
- Swift package usage (`Dependencies/Core/Package.swift`, `Dependencies/Runtime/Package.swift`)
- Xcode app project/workspace (`ActionStatus.xcodeproj`, `ActionStatus.xcworkspace`)
- SwiftUI usage (`CoreUI` views and app entry points)
- GitHub-integrated workflows (repo domain behavior and GitHub-related configuration/docs)

## Unresolved local-vs-shared instruction conflicts

- None found. Local rules (platform targets, code placement, required validation script) were preserved.
