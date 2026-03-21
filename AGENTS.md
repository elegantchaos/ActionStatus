## Project Specific Rules

- This repository contains ActionStatus, a cross-platform Apple app for monitoring GitHub Actions, with shared product logic in `Dependencies/Core/`.
- Target iOS 26.0+, tvOS 26.0+, and macOS 26.0+.
- Use Swift 6.2 and modern concurrency.
- Use Swift Testing, not XCTest.
- Use SwiftUI over UIKit/AppKit patterns.
- Keep the Xcode app target as a thin wrapper around `Dependencies/Core/`.
- Keep shared application code in `Dependencies/Core/` when possible.
- Treat the other packages in `Dependencies/` as local copies of external libraries, and reuse them before duplicating functionality.
- Create new library packages in `Dependencies/` when modularisation materially improves the design.

## Standard Rules

- Always write good code. Apply DRY and single-source-of-truth rules; prefer KISS, YAGNI, make-illegal-states-unrepresentable, dependency injection, composition over inheritance, command-query separation, least knowledge, structured concurrency, design by contract, and idempotency.
- Understand request boundaries, inspect relevant code and docs before editing, apply the smallest coherent change set, add or update tests for behavior changes, run relevant validation checks, and report changes, validation status, and residual risks.
- Use red/green TDD for non-view code.
- Add SwiftUI previews for view code.
- Follow the repository validation workflow and report skipped checks or validation gaps.
- Use trusted primary sources for technical decisions.
- Use portable `~/...` paths when pointing to shared local guidance.
- Never expose or commit credentials or secrets.
- Do not perform irreversible destructive actions without explicit approval. Reversible tracked-file deletions do not require extra approval beyond the user's request.
- Avoid unrelated refactors during focused tasks (but note them for later).
- If unexpected workspace changes appear, pause and confirm direction.
- For repository-maintained automation and helper scripts, prefer Swift unless the host environment requires another format.

## Skills

- Use `~/.local/share/skills/coding-standards-skill/SKILL.md` for cross-language engineering policy, maintainability, and trusted-source guidance.
- Use `~/.local/share/skills/swift-skill/SKILL.md` for baseline Swift language, organization, error-handling, and localization guidance.
- Follow `~/.local/share/skills/SwiftUI-Agent-Skill/swiftui-pro/SKILL.md` for SwiftUI architecture, API, accessibility, and performance guidance.
- Follow `~/.local/share/skills/Swift-Concurrency-Agent-Skill/swift-concurrency-pro/SKILL.md` for Swift concurrency guidance.
- Follow `~/.local/share/skills/Swift-Testing-Agent-Skill/swift-testing-pro/SKILL.md` for Swift Testing guidance.
- Use `~/.local/share/skills/validation-flow-skill/SKILL.md` when validating code changes.
- Use `~/.local/share/skills/refresh-hygiene-skill/SKILL.md` for repository hygiene work.
- Use `~/.local/share/skills/codex-git-skill/SKILL.md` for git operations.
- Use `~/.local/share/skills/codex-github-skill/SKILL.md` for GitHub operations.

To refresh this file, use the `~/.local/share/skills/refresh-agents-skill/SKILL.md` skill.
