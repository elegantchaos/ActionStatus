## Organisation

- Utility code is organized into Swift packages under `Dependencies/` for modularity and reuse.
- The Xcode target is a thin wrapper for platform-specific concerns.
- The main application logic is in `Dependencies/Core/`
- The Core package is split into two layers:
  - `Core`: platform-agnostic logic, including domain models, services, and protocols.
  - `CoreUI`: SwiftUI views, view models, and persistence implementations (e.g. Keychain-backed auth service).

## Key Patterns


A number of Services are defined, each responsible for a specific domain (e.g. authentication, notifications, etc). 

Services are injected into the SwiftUI environment and consumed by views and other components as needed.

Services are @Observable and publish changes to their state, which can be observed by views to update the UI reactively.

Services may depend on other services, but dependencies are explicit and injected at the top level (Engine) to avoid hidden coupling.

Services are intended to be mockable and testable in isolation, with clear protocols defining their behavior.

Views use @AppStorage (with the Settings package), to access user preferences directly.

Views are intended to be previewable and testable, with minimal logic and clear separation from domain services.

The Engine is responsible for coordinating service initialization, dependency injection, and high-level app lifecycle events. It is the composition root of the application.

