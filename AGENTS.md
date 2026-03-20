# ActionStatus — AI Coding Agent Guide

This repository contains ActionStatus, an Xcode app for iOS, tvOS, and macOS, with shared logic in the local Swift package under `Dependencies/Core/`.

See <https://actionstatus.elegantchaos.com/> for product context.

## Project Specific Rules

- Target iOS 26.0+ and/or macOS 26.0+.
- Use Swift 6 and modern concurrency.
- Use Swift Testing and not XCTest for unit tests.
- Avoid UIKit/AppKit patterns; prefer cross-platform SwiftUI.
- `Dependencies/Core` contains the core functionality for the application.
- The Xcode target is a thin layer wrapping Core. Keep it as small as possible.
- Other packages in `Dependencies/` are local copies of external libraries.
- Consider creating new library packages in `Dependencies/` to improve modularisation.
- Keep application code in `Dependencies/Core` when possible.
- Avoid duplication: use existing library code unless there is a clear reason to duplicate or reimplement.  

## Standard Rules

- Always write good code and keep behavior, tests, and docs aligned.
- Use red/green TDD for non-UI code.
- Create previews for SwiftUI code.
- Apply DRY and single-source-of-truth rules, and prefer KISS, YAGNI, make-illegal-states-unrepresentable, explicit dependencies, composition over inheritance, command-query separation, least knowledge, structured concurrency, design by contract, and idempotency.
- Prefer minimal, focused changes that solve the requested problem.
- Prefer fixing root causes over layered workarounds.
- Modernise or adopt a new architecture/style if appropriate, but avoid leaving mixed styles behind without a clear reason.
- Understand request boundaries, inspect relevant code/docs before editing, apply the smallest coherent change set, add or update tests for behavior changes, run relevant validation checks, and report changes, validation status, and residual risks.
- Prioritize correctness, clarity, and maintainability.
- Keep interfaces explicit and intentionally small.
- Avoid hidden coupling and surprising side effects.
- Do not add dependencies without clear justification.
- Never expose or commit credentials/secrets.
- For repository-maintained automation and helper scripts, prefer Swift unless the host environment requires another format.
- Do not perform irreversible destructive actions without explicit approval.
- Avoid unrelated refactors during focused tasks.
- If unexpected workspace changes appear, pause and confirm direction.

## Skills

- Follow `~/.local/share/agents/references/languages/Swift.md` for Swift file organization, error handling, localization, and platform-aligned modern Swift usage.
- Follow the SwiftUI guideance in `~/.local/share/skills/SwiftUI-Agent-Skill/swiftui-pro/SKILL.md`
- Follow the Swift concurrency guideance in `~/.local/share/skills/Swift-Concurrency-Agent-Skill/swift-concurrency-pro/SKILL.md`.
- Follow the Swift testing guideance in `~/.local/share/skills/Swift-Testing-Agent-Skill/swift-testing-pro/SKILL.md`.
- Use `~/.local/share/skills/codex-git-skill/SKILL.md` for git operations.
- Use `~/.local/share/skills/codex-github-skill/SKILL.md` for GitHub operations.
- Use `~/.local/share/skills/validation-flow-skill/SKILL.md` when validating code changes.
- Use `~/.local/share/skills/refresh-hygiene/SKILL.md` to maintain hygiene when writing, organising and reviewing code or documentation.

### Refresh

To refresh this file, use the `~/.local/share/skills/refresh-agents-skill/SKILL.md` skill.
