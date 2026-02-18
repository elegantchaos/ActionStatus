# SwiftUI Guidelines

## Architecture and state

- Back SwiftUI views with testable non-view logic where practical.
- Prefer cross-platform SwiftUI approaches when available.
- Use the existing state patterns in the codebase, and favor migration-friendly patterns for future Swift 6 work.
- Keep mutable state minimal and derive display state when possible.

## Naming

- General custom views: suffix with `View`.
- Control-like custom views: suffix with control type (`Button`, `Picker`, etc.).
- List/table rows: suffix with `Row`.
- View models: suffix with `ViewModel`.
- Protocols: descriptive nouns or capability names (`-able`/`-ible`).

## Property wrapper order in views

1. `@Environment`
2. `@Binding`
3. plain stored inputs
4. local `@State`

Also:
- Use `@Bindable` when binding into `@Observable` state.
- Prefer `@State private var` for local view-owned mutable state.

## Composition

- Do not split subviews into computed properties; create dedicated `View` structs.
- Avoid `AnyView` unless absolutely necessary.
- Prefer `some View` return types.

## Styling and layout

- Use `foregroundStyle()` over `foregroundColor()`.
- Use `clipShape(.rect(cornerRadius:))` over `cornerRadius()`.
- Avoid `UIScreen.main.bounds`.
- Avoid `GeometryReader` when modern alternatives are sufficient.
- Avoid hard-coded spacing/padding unless required.

## Navigation and interaction

- Use `NavigationStack`.
- Use `navigationDestination(for:)`.
- Prefer `Button` to `onTapGesture()` unless tap count/location is required.
- Use modern `Tab` APIs; do not use `tabItem()`.
- Use 0-parameter or 2-parameter `onChange`; avoid the 1-parameter form.

## Assets and previews

- If a button uses an icon, include text in the label.
- Prefer `ImageRenderer` over `UIGraphicsImageRenderer`.
- Add a `#Preview` for every custom `View`.

## Platform specialization

- Prefer cross-platform SwiftUI views.
- Specialize only when necessary.
- Prefer excluding at call sites for narrowly used platform-specific views.
- Keep platform-specific branches isolated in small extensions/subviews.
- UIKit/AppKit are acceptable when needed for platform-specific behavior (for example Catalyst bridge integrations).
