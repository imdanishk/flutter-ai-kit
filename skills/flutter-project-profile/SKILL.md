---
name: flutter-project-profile
description: Detects a Flutter project's stack, folder layout, conventions and commands, and records a short profile in AGENTS.md. Use when starting work in a Flutter repository that has no project profile, after the stack changes, or when asked to document the project's conventions.
license: Apache-2.0
---

# Flutter project profile

The profile tells every later task how this project does things, so work matches the existing code instead of generic defaults. Existing project conventions always win over anything in these skills.

## Steps

1. **Read the evidence, do not guess.** Open `pubspec.yaml`, `.fvmrc` (if present), `analysis_options.yaml`, the top two levels of `lib/`, `build.yaml`, and the flavor entry points (`lib/main*.dart`). Note which packages are used for:
   state management, dependency injection, routing, networking or GraphQL, local storage, localization, code generation, and error reporting.
2. **Find the exemplar feature.** Pick the most complete, recently changed feature that has presentation, domain and data code (`git log --name-only -n 40 -- lib` helps). List its files. Later tasks copy this feature's shape.
3. **Read the exemplar and write down how it does each of these**, citing the file:
   - state classes (Freezed, Equatable, plain) and how load or submit progress is represented
   - what repositories return (plain values, exceptions, a result or Either type)
   - how a page creates its cubit or bloc, and how side effects (snackbar, navigation) are handled
   - forms and validation, pagination, error messages, user-visible strings
   - how dependencies are registered and how routes are declared
   - import style (package or relative) and naming
4. **Find the commands.** Is the Flutter version pinned with FVM? What is the code generation command? Are there flavors or `--dart-define` files? Is there a format or lint step beyond `flutter analyze`?
5. **Write the profile** between these markers in the project's `AGENTS.md` (create the file if needed, never edit outside the markers):

```
<!-- flutter-ai-kit:profile:start -->
## Project profile
- Stack: <state, DI, routing, network, storage>
- Layout: <lib/ layers or feature folders>
- Exemplar feature: <path>
- Conventions: <5 to 10 short lines, each naming the file that shows it>
- Commands: <fvm prefix if any; codegen; analyze; run with flavor>
- Unknown: <anything you could not determine>
<!-- flutter-ai-kit:profile:end -->
```

6. **Ask at most five questions** about anything ambiguous or contradictory (for example two state management styles in one repo: which one is the target?). Do not fill gaps with assumptions; list them under `Unknown`.

## Rules

- Keep the profile under 40 lines. It is loaded into every task, so every line must change what an agent would do.
- Describe what the code does today, not what you would prefer.
- If the repository already has a profile block, update it in place and say what changed.
