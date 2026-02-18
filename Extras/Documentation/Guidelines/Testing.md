# Testing Guidelines

## Baseline expectations

- Add unit tests for new behavior.
- Use the existing test style in the repository, and prefer migration-friendly test patterns.
- Prefer unit tests over UI tests when feasible.

## Validation commands

- Full validation after changes: `Extras/Scripts/validate-changes`
- Target-focused validation: `Extras/Scripts/validate-target <target-name>`

## Test design

- Test via public/internal interfaces; avoid `@testable import` where practical.
- If needed, expose minimal test-support API and clearly label it as testing-only.
- Keep tests explicit and readable.
- Extract shared test helpers only when it reduces repetition without hiding intent.

## Coverage guidance

- Prefer focused tests on changed behavior and edge cases.
- For untested legacy code touched by a change, add tests where practical.
- Document known gaps when a full test is not feasible.
