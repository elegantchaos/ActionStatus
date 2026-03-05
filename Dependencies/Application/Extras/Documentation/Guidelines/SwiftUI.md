# SwiftUI Guidance

Relevance: include this file when the project uses SwiftUI views, state wrappers, navigation APIs, or SwiftUI-specific architecture.

## Why this file exists

This module defines SwiftUI-specific guidance to keep view code maintainable, testable, and aligned with modern APIs.

## Architecture and State

- Keep mutable view state minimal and derive display state where possible.
- Prefer testable non-view logic for business behavior.
- Follow existing project state patterns unless migration is intentional.

## Composition

- Prefer small dedicated view types over large monolithic views.
- Avoid `AnyView` unless type erasure is necessary.
- Use `some View` where feasible.

## Property Wrapper Usage

- Keep wrapper usage intentional and readable (`@Environment`, `@Binding`, inputs, local `@State`).
- Use `@Bindable` with observable models when it improves correctness.

## Styling and Layout

- Prefer modern SwiftUI styling APIs over deprecated/legacy forms.
- Avoid device-size globals and layout hacks when native layout tools suffice.
- Keep spacing and sizing consistent with project design conventions.

## Navigation and Interaction

- Prefer modern navigation APIs and explicit destinations.
- Prefer semantic controls (`Button`) over generic gesture handlers when suitable.
- Use modern API forms for change observation and tab/navigation constructs.

## Previews and Assets

- Add meaningful previews for custom views where practical.
- Ensure icon-only affordances remain accessible with descriptive labels.

## Platform Specialization

- Prefer cross-platform SwiftUI implementations.
- Isolate platform-specific branches in focused helpers or extensions.
- Use UIKit/AppKit interop only where required by behavior.
