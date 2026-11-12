# Upgrade checklist

Sources read 2026-11-08: dart.dev/tools/pub/cmd/pub-upgrade, dart.dev/tools/pub/cmd/pub-outdated, docs.flutter.dev/release/upgrade, docs.flutter.dev/release/breaking-changes, fvm.app/documentation/guides/basic-commands. Lines marked *Not verified* are practice, not read on an official page.

An upgrade is its own change, on its own branch, with nothing else in it. Never upgrade right before a release.

## 0. Before

- Working tree clean, on a new branch (`flutter-git`). Note the starting point: `flutter --version`, Dart version, and the lockfile (commit `pubspec.lock` for an app).
- Ask what is wanted: packages only, Dart or Flutter SDK, or both; and which channel (stable for production; the Flutter upgrade page does not recommend `main`).
- If `.fvmrc` exists, every command below runs with the `fvm` prefix.

## 1. Packages

1. See what is outdated: `dart pub outdated` (or `flutter pub outdated`).
   - **Current**: the version in `pubspec.lock`.
   - **Upgradable**: the newest your `pubspec.yaml` constraints allow; what `pub upgrade` gets.
   - **Resolvable**: the newest that works with all your other dependencies if constraints were unbounded; editing `pubspec.yaml` to match is usually the fix.
   - **Latest**: the newest published. Add `--transitive` to include transitive dependencies. The page's own statements on prereleases conflict (`--prereleases` versus `--no-prereleases`); check `dart pub outdated --help` for your version.
   - **If Flutter or Dart cannot be run** (a sandbox, a review-only task): say so, read the constraints in `pubspec.yaml` and the resolved versions in `pubspec.lock`, and look each package up on pub.dev (version, publish date, changelog tab). Mark the plan "not run" and give the developer the commands to run; do not invent "Upgradable" or "Resolvable" columns.
   - **Find what is held back before choosing any major upgrade.** For every direct dependency where Upgradable or Resolvable is below Latest, find out why: another package's constraint (`dart pub deps`, or the message from `dart pub upgrade --dry-run`), or an SDK pin (`intl` is pinned by `flutter_localizations`). Companion packages must move together or not at all (for example `get_it` with `get_it_mixin`, `bloc` with `flutter_bloc`, the Riverpod packages). Report these blockers first; do not edit constraints to find out.
   - **A plan-only request, or a project rule against dependency changes,** means stop after the plan; do not run the first step.
2. Preview: `dart pub upgrade --dry-run` (`-n`). It changes nothing.
3. Compatible upgrades: `dart pub upgrade` raises everything inside the constraints and rewrites `pubspec.lock`, not `pubspec.yaml`. To upgrade named packages only: `dart pub upgrade <package>`; add `--unlock-transitive` to also unlock their transitive dependencies.
4. Major versions: `dart pub upgrade --major-versions` raises constraints in `pubspec.yaml` to what `outdated` lists as resolvable. Ask first, and prefer naming the package. Before each major upgrade, read that package's changelog and migration notes for the versions in between.
5. `dart pub upgrade --tighten` raises lower bounds to the resolved versions; useful for packages, optional for apps.
6. After any change: run `dart pub get` if needed, then code generation if the project uses it (build_runner packages are the usual source of generated-file diffs; do not hand-edit them), then `dart analyze`.

## 2. Dart and Flutter SDK

1. Read the breaking changes for every release between the current version and the target: docs.flutter.dev/release/breaking-changes lists them by release ("Released in Flutter X.Y"), each with a migration guide. The page warns that guides are accurate only for the release they were written under.
2. With FVM:
   - `fvm releases` lists releases (stable by default; `--channel beta` or `--channel all` for others).
   - `fvm install <version>` downloads one; `fvm list` shows installed ones.
   - `fvm use <version>` in the project updates `.fvmrc`, creates `.fvm/` and runs `flutter pub get`. The page read does not say what to commit; follow the project's existing `.gitignore` and commit `.fvmrc` so the team shares the pin *(not verified)*.
3. Without FVM: `flutter upgrade` moves to the newest on the current channel; `flutter channel` shows and switches channel. The upgrade page does not describe going back to a specific version other than checking out that tag in the SDK folder, which is the developer's call, not a default.
4. `dart fix --dry-run` shows automated migrations for deprecated APIs; `dart fix --apply` applies them. The breaking-changes page says many, not all, breaking changes are covered this way. Review the diff.
5. Fix what remains by hand, one error group at a time, following the migration guides. Windows only: a "Filename too long" error during `flutter upgrade` means a shorter install path or long paths enabled (see the upgrade page).

### Flutter 3.50 and Dart 3.14 (released 2026-11-11)

Read from Flutter's "What's new in Flutter 3.50", the Dart 3.14 announcement and the migration guide at docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui, on 2026-11-12.

- **Material and Cupertino become packages.** `package:flutter/material.dart` and `cupertino.dart` are formally deprecated in 3.50 in favour of the standalone `material_ui` and `cupertino_ui` packages (1.0 shipped from Flutter 3.47; the in-SDK code was frozen in 3.44; new projects use `material_ui` by default). The pages do not say when the old imports are removed or whether they still compile in 3.50 *(Unverified: expect deprecation warnings, not errors; check on your project)*.
  - Migrate as its own step, after the Flutter upgrade builds: `dart fix --apply --code=migrate_design_widgets` (rewrites imports to `package:material_ui/material_ui.dart` and `package:cupertino_ui/cupertino_ui.dart`); if it does not add the dependencies, `flutter pub add material_ui` and `flutter pub add cupertino_ui`; then run `dart fix` again for lint and import-order fixes. Ask before starting; it touches every UI file.
  - **Localization:** the Material and Cupertino delegates move too. `localizationsDelegates: GlobalMaterialLocalizations.delegates` from `material_ui` includes the Cupertino and Widgets delegates; `flutter_localizations` stays a dependency for the rest. See `flutter-feature/references/localization-recipe.md`.
  - **Third-party packages** that still import the old libraries can be bridged with `MaterialUiCompatibilityBridge` (wrap the app in `MaterialApp.builder`); it cannot fix packages whose public API takes or returns legacy types (`ColorScheme`, `TextTheme`, `FloatingActionButtonLocation`), which must be updated first. Do not mix both libraries in one file by accident; follow what the project imports today.
  - Packages you publish: treat the switch as a major version bump (the guide says so).
- **`dart migrate` (new in Dart 3.14)** moves a package one minor SDK version per run: applies preparatory `dart fix` fixes, raises the SDK lower bound in `pubspec.yaml`, offers cleanup fixes. Flags: `--dry-run`, `--apply`, `--step`, `--target-sdk`. It supports only packages whose SDK constraint already requires Dart 3.0 or later. Start with `--dry-run`. *(Read on the announcement only; not run.)*
- **Legacy web libraries** (`dart:html`, `dart:js`, `dart:js_util`, `package:js`) are deprecated and will be removed; `dart compile js` and `ddc` take `--no-deprecated-js-interop` to find them. Web builds only.
- Smaller 3.50 breaking changes: `ignoringSemantics` is removed from `IgnorePointer`, `AbsorbPointer` and `SliverIgnorePointer`; soft hyphens now show a hyphen where a word wraps; `WidgetSpan` order in right-to-left text follows reading order; `SafeArea` on mobile web respects `viewport-fit=cover`.

## 3. Native side

A new Flutter version can require newer Android Gradle plugin, Gradle, Kotlin and Java versions and a newer Xcode, and Play and App Store rules add dated requirements (16 KB pages, target API, UIScene, SwiftPM). Read `native-platform-requirements.md` for the dated tables and checks. If a build fails in `android/` or `ios/`, read the first error, then the migration guide for that Flutter version. Do not edit native files without saying so; name them in the report.

## 4. Check

- `dart analyze` is clean, or every remaining item is listed.
- App builds for each platform you can build on this machine (say which you could not).
- Run the main flows if the app can be run; say if not.
- Compare the package list before and after (`dart pub outdated`, or the diff of `pubspec.lock`) and put the notable changes (major bumps, removed or added transitive packages) in the report.

## 5. Report

Versions before and after (SDK, Dart, each changed direct package), breaking changes handled and where, native changes made, what was checked and what was not, packages left behind and why (a constraint, a missing release, a decision to wait), and anything that needs a decision.
