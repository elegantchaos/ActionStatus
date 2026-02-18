# ActionStatus

Action Status is a small utility for macOS, iOS and tvOS, which displays the status of Github Actions.

It also allows you to auto-generate workflows to test your Swift projects against a matrix of Swift versions and platforms.

A pre-build version is available for free download in the App Store. 

For more information, see https://actionstatus.elegantchaos.com.


## Coding Guidelines

This project keeps coding guidance in `Extras/Documentation/Guidelines/`.

If you are contributing code, start with:

- `Extras/Documentation/Guidelines/README.md`
- `Extras/Documentation/Guidelines/Principles.md`
- `Extras/Documentation/Guidelines/Swift.md`
- `Extras/Documentation/Guidelines/SwiftUI.md`
- `Extras/Documentation/Guidelines/Testing.md`
- `Extras/Documentation/Guidelines/Trusted Sources.md`

Quick summary:

- Keep changes small and in the correct layer, with shared logic in `Dependencies/Core/` where possible.
- Prefer simple, maintainable Swift and SwiftUI patterns used in the existing codebase.
- Add or update tests for behavior changes.
- Localize all user-facing strings.
- Run `Extras/Scripts/validate-changes` before finalizing changes.

For coding and design context, see the guideline documents under `Extras/Documentation/Guidelines/`.
