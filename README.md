# ActionStatus

Action Status is a small utility for macOS, iOS and tvOS, which displays the status of Github Actions.

It also allows you to auto-generate workflows to test your Swift projects against a matrix of Swift versions and platforms.

A pre-build version is available for free download in the App Store. 

For more information, see https://actionstatus.elegantchaos.com.


## Coding Guidelines

This project keeps agent-facing coding guidance in `AGENTS.md`.

If you are contributing code, start with:

- `AGENTS.md`
- `~/.local/share/agents/references/Principles.md`
- `~/.local/share/agents/references/languages/Swift.md`
- `~/.local/share/agents/references/Validation.md`
- `~/.local/share/agents/references/Trusted Sources.md`
- `~/.local/share/skills/SwiftUI-Agent-Skill/swiftui-pro/SKILL.md`

Quick summary:

- Keep changes small and in the correct layer, with shared logic in `Dependencies/Core/` where possible.
- Prefer simple, maintainable Swift and SwiftUI patterns used in the existing codebase.
- Add or update tests for behavior changes.
- Localize all user-facing strings.
- Run `Extras/Scripts/validate-changes` before finalizing changes.

For coding and design context, see `AGENTS.md` and the shared references it points to.
