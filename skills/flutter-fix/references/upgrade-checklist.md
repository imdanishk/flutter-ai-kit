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

## 3. Native side *(not verified; check the Flutter migration guides for the target version)*

A new Flutter version can require newer Android Gradle plugin, Gradle, Kotlin or Java versions, and newer Xcode or CocoaPods settings. If the build fails in `android/` or `ios/`, read the first error, then the migration guide for that version. Do not edit native files without saying so (they are named in the report).

## 4. Check

- `dart analyze` is clean, or every remaining item is listed.
- App builds for each platform you can build on this machine (say which you could not).
- Run the main flows if the app can be run; say if not.
- Compare the package list before and after (`dart pub outdated`, or the diff of `pubspec.lock`) and put the notable changes (major bumps, removed or added transitive packages) in the report.

## 5. Report

Versions before and after (SDK, Dart, each changed direct package), breaking changes handled and where, native changes made, what was checked and what was not, packages left behind and why (a constraint, a missing release, a decision to wait), and anything that needs a decision.
