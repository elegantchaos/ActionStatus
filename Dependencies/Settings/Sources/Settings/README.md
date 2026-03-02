# StackSettings

## Purpose
`StackSettings` defines the app settings key system.

It provides typed setting keys and access helpers used by services and UI to read and write persisted preferences consistently.

## Responsibilities
- Define canonical app setting keys.
- Provide typed bridges for `UserDefaults` and `AppStorage`.
- Keep preference key usage consistent across modules.
