---
name: flutter-feature
description: Adds or changes a feature, screen, form or list in an existing Flutter project by following the project's own conventions, then regenerates code and runs the analyzer. Use when asked to build, extend or modify app functionality.
license: Apache-2.0
---

# Flutter feature

## Steps

1. **Load the project profile** from `AGENTS.md`. If there is none, run the `flutter-project-profile` skill first.
2. **Open the exemplar feature** named in the profile and the closest existing feature to this request. Plan the new files by mirroring it, layer by layer. For a change touching more than three files, or when the request is ambiguous, show the plan (file, purpose, one line each) and the assumptions before writing code. For a small, clear change, just do it.
3. **Reuse before creating.** Search for an existing status type, form field state, result type, validators, shared widgets, string table or localization keys. Use them. Do not introduce a second way of doing something the project already does.
4. **Implement in dependency order:** domain, data, state, cubit or bloc, page, dependency registration, route, strings. Keep business logic out of widgets.
5. **Generate and check.** Run code generation if you touched annotated files, then `flutter analyze` (with the `fvm` prefix when the version is pinned). Fix what the analyzer reports. Never edit generated files.
6. **Finish with a short summary:** files added and changed, assumptions made, and anything the developer must still do by hand (native configuration, backend changes, keys, store settings).

## Watch for these (the usual causes of rework)

- Using `BuildContext` after an `await` without checking `context.mounted`.
- Emitting state after a cubit or bloc is closed.
- A load or submit that can never leave the loading state because its error path is missing.
- One shared status for operations that run side by side (load list and delete item need their own).
- Controllers, focus nodes, timers or stream subscriptions that are never disposed or cancelled.
- User-visible text outside the project's string table or localization.
- A new package added without asking, or a new feature that needs Android or iOS configuration (permissions, manifest, `Info.plist`, entitlements) and does not say so.
- Business logic or data access called straight from a widget.

## References

- `references/bloc-freezed-recipe.md`: a complete feature slice for the Cubit, Freezed, injectable and auto_route stack. Read it only when the project uses that stack and has no suitable exemplar, or when asked to start a feature from scratch.
