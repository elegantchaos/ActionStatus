# Swift Guidelines

## Platform and language

- Target iOS 26.0+ and/or macOS 26.0+.
- Codebase language level is currently Swift 5.x.
- Implement new changes with Swift 6 migration in mind (prefer modern concurrency-safe patterns where practical).
- Default UI-facing types to `@MainActor` when it improves correctness; explicitly justify non-main-actor types.

## File organization

- Prefer one primary type per file.
- Name files after the type (`MyType.swift`).
- For focused extensions, use `MyType+Functionality.swift`.
- For protocol-conformance files, use `MyType+ProtocolName.swift`.
- Use PascalCase file names.

In each Swift file, prefer this order:
1. imports
2. log channels (if any)
3. main type definition
4. helper types/extensions
5. `#Preview` at the bottom for SwiftUI view files

## Type organization

For classes/structs, prefer this order:
1. stored properties
2. initializers
3. computed properties
4. public methods
5. private methods (often in private extensions)

For enums, prefer:
1. cases
2. static constants/factories
3. computed properties

For protocols, prefer:
1. properties
2. methods

## Documentation comments

- Add `///` docs to all types and members, including private members.
- Explain intent/behavior, not just the symbol name.
- Add inline comments only where intent is not obvious.

## Core coding conventions

- Prefer Swift-native APIs over older Foundation patterns.
- Prefer static member lookup where it improves readability.
- Avoid force unwraps and `try!` unless failure is unrecoverable.
- Prefer value types unless reference semantics are required.
- Mark classes `final` unless inheritance is intentional.
- Keep visibility tight (`private` by default, `public` only when necessary).
- Avoid private single-line wrappers unless they add clear value.

## Concurrency

- Prefer Swift concurrency (`Task`, `await`, actors) for new code.
- Minimize new `DispatchQueue` usage unless required by existing APIs.
- Use actors for shared mutable state when practical.

## Error handling

- Use `throws` / `async throws` for failure paths.
- Use `Result` when success/failure must be stored or passed as state.
- Use optionals only when absence is a valid non-error outcome.
- Prefer domain-specific error enums.

## String filtering

- For user-input filtering, use `localizedStandardContains()`.

## Localization

- Localize all user-facing strings.
- Use dot-separated localization keys.
- Prefer generated string catalog symbols when available.
