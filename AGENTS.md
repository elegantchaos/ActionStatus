# ActionStatus — AI Coding Agent Guide

This repository contains ActionStatus, an Xcode app for iOS, tvOS, and macOS, with shared logic in the local Swift package under `Dependencies/Core/`.

See <https://actionstatus.elegantchaos.com/> for product context.

## Project Specific Rules

- Target iOS 26.0+ and/or macOS 26.0+.
- The codebase uses Swift 6 and modern concurrency.
- The codebase still contains UIKit/AppKit patterns; prefer deliberate moves toward cross-platform SwiftUI.
- Keep code in `Dependencies/Core` when possible.
- Consider creating new library packages in `Dependencies/` to improve modularisation.
- Minimize the size of `Sources/ActionStatusMobile`, `Sources/ActionStatusTV`, and `Sources/ActionStatusMac`.
- Relevant repo files: `README.md`, `Settings.xcconfig`, `ActionStatus.xcodeproj/project.pbxproj`.

## Standard Rules

- Always write good code and keep behavior, tests, and docs aligned.
- Use red/green TDD for non-UI code.
- Create previews for UI code.
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
- Follow the validation workflow in `~/.local/share/agents/references/Validation.md`, and use `~/.local/share/skills/validation-flow-skill/SKILL.md` for standard validation when it applies.
- Use trusted primary sources for technical decisions and external references, following `~/.local/share/agents/references/Trusted Sources.md`.
- Follow `~/.local/share/agents/references/languages/Swift.md` for Swift file organization, error handling, localization, and platform-aligned modern Swift usage.
- Use `~/.local/share/skills/SwiftUI-Agent-Skill/swiftui-pro/SKILL.md` for SwiftUI-specific guidance, `~/.local/share/skills/Swift-Concurrency-Agent-Skill/swift-concurrency-pro/SKILL.md` for concurrency decisions, and `~/.local/share/skills/Swift-Testing-Agent-Skill/swift-testing-pro/SKILL.md` for Swift Testing guidance.
- Use `~/.local/share/skills/codex-git-skill/SKILL.md` for git operations and `~/.local/share/skills/codex-github-skill/SKILL.md` for GitHub workflows.
- Do not perform irreversible destructive actions without explicit approval.
- Avoid unrelated refactors during focused tasks.
- If unexpected workspace changes appear, pause and confirm direction.
- For `gh` commands with Markdown bodies, use `--body-file` rather than inline `--body`.
- Keep PR summaries factual, scoped to the diff, and include validation/gaps.
- Add compact documentation comments for each type, method/function, and member/property describing purpose.
- Comments should add intent/context, not restate names.
- For the primary type in a source file, add a top-level documentation comment with design/implementation detail.
- Keep inline comments sparse and focused on subtle logic or constraints.

To refresh this file, use the `~/.local/share/skills/refresh-agents-skill/SKILL.md` skill.
