---
name: flutter-new-project
description: Sets up the structure of a new Flutter app (folders, shared core types, dependency injection, routing, code generation, optional FVM pin) using the Cubit, Freezed, injectable and auto_route stack. Use when starting a new Flutter project or adding the base architecture to an empty one.
license: Apache-2.0
---

# Flutter new project

Use only for a new or empty project. For an existing project, run `flutter-project-profile` instead and follow what is there.

## Steps

1. **Confirm choices** (ask only what is not already stated; offer these defaults):
   - project name and organization id
   - platforms (default Android and iOS)
   - Flutter version pinned with FVM (default yes; ask which version, or use the current stable)
   - stack: Cubit with Freezed, injectable with get_it, auto_route (default). If the developer wants another stack, build it from their choice and skip the assets below.
   - flavors (dev, staging, prod) now or later (default later)
2. **Create the app** with `flutter create` (prefix `fvm` when pinned: `fvm use <version>` first, then `fvm flutter create .`). Commit `.fvmrc`; ignore `.fvm/` in git.
3. **Add packages with the package manager**, not by hand-editing versions: `flutter pub add flutter_bloc bloc freezed_annotation injectable get_it auto_route` and `flutter pub add --dev build_runner freezed injectable_generator auto_route_generator`. Read the resolved versions and tell the developer if any generator constraint forced a downgrade.
4. **Create the layout** described in `references/layout.md`.
5. **Copy the shared core** from `assets/core/` into `lib/core/` and fix nothing else in it. These files are small, dependency-free apart from `flutter_bloc`, and are what the `flutter-feature` recipe expects.
6. **Wire the base**: `lib/app/injection.dart` (injectable `configureDependencies`), `lib/app/router.dart` (an `AppRouter` with one home route), `lib/main.dart` calling `configureDependencies()` then `runApp(MaterialApp.router(...))`.
7. **Generate and verify:** `dart run build_runner build --delete-conflicting-outputs` (prefixed with `fvm`), then `flutter analyze` and a run on one device. Add generated files (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `*.config.dart`) to `.gitignore` only if the team agreed; otherwise commit them.
8. **Record the profile**: run `flutter-project-profile` so `AGENTS.md` describes the new project.

## Rules

- Do not add packages that were not discussed (analytics, crash reporting, localization, storage, networking). Ask, and name the Android and iOS setup each one needs.
- Do not create tests unless the developer asks.
- Stop and report any step that fails, with the command and its output, rather than working around it silently.
