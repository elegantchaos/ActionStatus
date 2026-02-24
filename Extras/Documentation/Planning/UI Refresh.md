# UI Refresh and Dependency Simplification Plan

This plan modernizes the app's SwiftUI usage across macOS, iOS, and tvOS, while removing unnecessary abstraction layers and YAGNI generalization.

## Phase 1: Remove No-Value Imports and Dead Generalization

Goals:
- Remove unused `SwiftUIExtensions` imports and other dead imports.
- Remove dead local code that exists only as generalization but is not used.
- Keep behavior unchanged.

Actions:
1. Remove `import SwiftUIExtensions` where no APIs from the package are used.
2. Remove other now-unused imports discovered while doing this cleanup.
3. Remove clearly unused environment dependencies and local helpers where safe.
4. Validate with `Extras/Scripts/validate-changes`.

Exit criteria:
- Reduced import and dependency noise with no behavior changes.
- Builds and tests pass for iOS, macOS, and tvOS.

## Phase 2: Replace SwiftUIExtensions Form/Layout Abstractions

Goals:
- Fix macOS repo settings UI layout issues.
- Replace package form abstractions with native SwiftUI.

Actions:
1. Replace `FormSection`/`FormRow`/`FormFieldRow`/`FormStyle` with native `Form`, `Section`, `LabeledContent`, and direct field layout.
2. Replace `AlignedLabelContainer` usage with native layout constructs.
3. Keep platform-specific layout differences explicit and minimal.
4. Validate visual behavior and run `Extras/Scripts/validate-changes`.

Exit criteria:
- Repo settings UI is stable and readable on macOS.
- Form/layout logic no longer depends on `SwiftUIExtensions` abstractions.

## Phase 3: Remove Cross-Platform Shim Layer (YAGNI Cleanup)

Goals:
- Remove compatibility shims that are no longer needed at current deployment targets.

Actions:
1. Remove `.shim` paths and use direct SwiftUI APIs.
2. Replace `.bindEditing` with explicit native edit-mode/state handling.
3. Remove shimmed text input modifiers where direct APIs are available.
4. Keep tvOS-only focus behavior explicit via `#if os(tvOS)` only where required.

Exit criteria:
- No remaining shim-based behavior in core UI flows.
- Platform behavior remains correct without generalized wrappers.

## Phase 4: Replace SheetController With Native SwiftUI Presentation

Goals:
- Remove controller-style sheet orchestration where native SwiftUI is sufficient.

Actions:
1. Migrate to `.sheet(item:)` / `.sheet(isPresented:)` with typed presentation state.
2. Remove `SheetControllerHost` and environment injection patterns where no longer needed.
3. Keep modal routing explicit and testable.

Exit criteria:
- Modal presentation uses native SwiftUI patterns.
- Controller indirection is removed from common UI flows.

## Phase 5: Decompose ApplicationExtensions Usage

Goals:
- Reduce lifecycle/scaffolding abstraction and adopt modern app lifecycle patterns.

Actions:
1. Audit `BasicApplication` / `BasicScene` usage.
2. Migrate lifecycle flow to native `@main App` + `Scene` patterns where feasible.
3. Inline or replace tiny utilities locally when cheaper than external dependency.

Exit criteria:
- `ApplicationExtensions` usage is minimized or eliminated in core app lifecycle paths.

## Phase 6: Dependency Prune and Package Topology Cleanup

Goals:
- Remove dependencies that no longer provide active value.

Actions:
1. Remove `SwiftUIExtensions` from package dependencies once call sites are gone.
2. Re-evaluate `ApplicationExtensions` and other generalized dependencies with strict YAGNI criteria.
3. Keep only dependencies with current, concrete value.

Exit criteria:
- Lean dependency graph with intentional, actively used packages only.

## Phase 7: Swift 6+ Modernization

Goals:
- Align the codebase with current Swift language/runtime expectations.

Actions:
1. Move to Swift 6 language mode progressively.
2. Address strict concurrency diagnostics.
3. Adopt modern observation/state patterns where it improves clarity.

Exit criteria:
- Project builds cleanly under Swift 6+ settings with modernized language usage.
