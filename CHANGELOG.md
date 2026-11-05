# Changelog

All notable changes are listed here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.10.1] - 2026-11-05

### Added
- `flutter-release`: GitHub Actions workflow templates for Android and iOS (manual trigger, per-flavor environments, Flutter version from `.fvmrc`, inputs passed through environment variables). Not run; action versions not re-checked.
- Google Play pre-release requirements from official pages: App content declarations, the Data safety form (per package name) and the account-deletion rule.

### Changed
- Apple's rule that the first In-App Purchase of each type must be submitted with a new app version, the subscription statuses, and the "Missing Metadata" wording are now verified or corrected from Apple's pages.

## [0.10.0] - 2026-11-04

### Added
- `flutter-testing`: writes and runs tests following the project's own test setup, only when the developer asks; patterns for cubit or bloc, repository, widget and integration tests.
- `flutter-service-setup`: `backend-handoff.md` - what to give the backend per feature (Google web client ID, Firebase service account, push, Maps server key, app-link fingerprints, Sign in with Apple), per platform and environment, with a one-page sheet.
- `flutter-release`: `ios-signing-and-match.md` - certificate and profile types, Xcode flavor configurations, match storage and `readonly`, first-time setup, a new teammate or CI machine, adding a device, expiry and revocation, and a troubleshooting table; guardrails for an agent that ships builds (inputs, preflight, order, final report).
- Fastlane templates: build numbers derived from the target store (Firebase, all Play tracks, TestFlight) with optional `release:patch|minor|major`, a tested `versioning.rb`, a `Matchfile`, and iOS lanes `certs_get`, `certs_create` and `add_device`; env files loaded per flavor.
- `flutter-project-profile` checks for the official Flutter and Dart skills and prints the install commands without installing.
- `tool/test_versioning.rb` and a CI step that runs it.

### Changed
- The AGENTS block names `flutter-testing` and points tests to it.
- iOS flavor setup is now verified from Flutter's iOS flavors page.

## [0.9.1] - 2026-11-04

### Added
- `flutter-service-setup`: backend hand-off for subscriptions - Google Play service account, permissions, Pub/Sub topic and push subscription, Apple In-App Purchase key, Issuer ID, App Store Connect API key, server notification URLs, per-environment separation and a confirm checklist. Permissions and notification requirements checked on Google's and Apple's pages; other steps marked as from a working team's guide.
- A working per-environment file layout (per-flavor Firebase files, keystores, service accounts, env files).

## [0.9.0] - 2026-11-04

### Added
- `flutter-service-setup`: what must exist before a feature works - one Firebase project per environment, flavors, SHA fingerprints (debug, upload and Play app signing keys), keystore handling, Maps and Places billing and key restrictions, Google sign-in setup, Apple's login and account-deletion rules, and subscriptions on Google Play and the App Store with sandbox and licence testing. Each reference carries a verified date and marks unverified lines.
- `flutter-release`: runbook from the command line to Firebase App Distribution, Google Play and TestFlight, store account and test track requirements, a CI/CD checklist with a drift check, and Fastlane Gemfile, Fastfile and env templates (Ruby syntax checked only).
- `flutter-git`: safe git defaults, never-commit list, branch, commit and pull request conventions.
- README: lifecycle table showing which skill covers which phase.

### Changed
- `flutter-feature` runs `flutter-service-setup` first when a feature needs consoles, keys or store products; `flutter-estimate` lists such waits as elapsed-time blockers.

## [0.8.0] - 2026-11-03

### Added
- Standing developer preferences: the `AGENTS.md` block tells agents to read a `Developer preferences` list and to add a line when the developer states a standing preference. The installer creates the list and never overwrites it.
- `refresh-reminder` workflow: opens a "Refresh feature notes" issue on the 1st and 15th of each month.
- `NOTICE` file with the copyright line.

### Changed
- `flutter-feature-notes` and `flutter-estimate`: compare entry dates with today, check current package pages and look for newer or better-maintained alternatives; the entry is not binding.
- Recipes: check current major versions before use.

## [0.7.0] - 2026-11-03

### Changed
- README: how it works, an example of the "Rule conflicts" line, what the kit will not do, and an honest status.
- Confirmed in a rerun on a real app that the summary lists rule conflicts (a precedent that breaks a written rule, a data-layer type used in presentation).

## [0.6.1] - 2026-11-03

### Changed
- `flutter-feature`: when a written rule and existing code disagree, follow the rule if possible; otherwise use the precedent and report it in a new "Rule conflicts" line of the summary.
- `flutter-review`: a rule broken by the diff is reported even when the code copies an existing pattern, marked "follows existing precedent".

## [0.6.0] - 2026-11-03

### Changed
- `flutter-feature` and `flutter-review` now read the project's own rules (`AGENTS.md`, `CLAUDE.md`, rules folders) first; the project rule wins over the kit. Review must name what it checked before saying "no findings", and recommends a second review when the author reviews its own code.
- `flutter-feature`: when code generation or the full analyzer cannot run, analyze the changed files only and report what was not checked.
- `flutter-project-profile`: adds a `Conflicts` line (docs versus code) and does not restate rules the project already documents.

## [0.5.4] - 2026-11-02

### Changed
- README: `npx skills add` needs `--yes` where it cannot ask questions (it otherwise installs nothing and still exits 0); note on using the kit next to the official Flutter and Dart skill sets.
- `flutter-project-profile`: works without git, and handles a brand-new project with no feature to learn from (records the stack, asks which target stack, points to `flutter-new-project`).

## [0.5.3] - 2026-11-02

### Changed
- Picture-in-Picture, Spotlight, wallet passes and TV entries now cite Apple's documentation (Apple's own rule: iOS Picture-in-Picture must start only from a user action; wallet pass signing and update service confirmed). Amazon lists Android, HTML5 and React Native for Fire TV, not Flutter, and the two tvOS package sources disagree on the minimum tvOS version.

## [0.5.2] - 2026-11-02

### Changed
- Passkeys, certificate pinning and iOS privacy manifest entries now cite Apple's own documentation (fetched through Apple's documentation JSON; see `docs/REFRESH.md`, "Pages that return no text"), with the Xcode steps, the pinning keys and the App Store upload rule.
- `docs/REFRESH.md`: how to read pages that return no text.

## [0.5.1] - 2026-11-02

### Changed
- Second verification pass on 12 feature entries. Now verified: integrity attestation, consent (GDPR, UMP). Corrections: Supabase passkeys are labelled experimental (not beta); `banuba_sdk` is 3.1.7 from a verified publisher; the Android shortcuts library is `core-google-shortcuts`; the Android `assetlinks.json` relation is named.
- 20 of 79 detailed entries remain partly verified (mostly because Apple, Amazon and vendor pricing pages return no readable text).

## [0.5.0] - 2026-11-01

### Added
- `flutter-new-project`: Riverpod variant.
- `flutter-review`: stack-specific checks for Cubit/bloc and Riverpod.

## [0.4.1] - 2026-11-01

### Changed
- Ride-sharing and logistics entries now cite the current `google_navigation_flutter` and `flutter_background_geolocation` package pages (requirements, licence). 20 of 79 detailed entries remain partly verified.

## [0.4.0] - 2026-10-31

### Added
- `flutter-feature` reference: Riverpod 3 feature recipe (hand-written providers, `AsyncNotifier`, `ref.mounted`, retry, independent operations, forms).

## [0.3.2] - 2026-10-31

### Changed
- Releases are now published automatically when the version in `.claude-plugin/plugin.json` changes on `main` (no manual tagging).

## [0.3.1] - 2026-10-31

### Changed
- Re-verified 55 of the detailed feature entries against current sources. Corrections include: Firebase App Check defaults to DeviceCheck on iOS (App Attest is opt-in); Google Play Instant is deprecated; `flutter_chat_ui` 2.x is a rewrite of 1.x; a third-party Camera Kit plugin exists.
- 22 of 79 entries remain partly verified or unverified (each says what is still to check).

## [0.3.0] - 2026-10-30

### Added
- Skill `flutter-feature-notes`: a feature index (about 230 features) and detailed, dated entries for sign-in and security, chat and social, commerce and maps, and data and platform surfaces, plus setup guides for data sharing, payments, media and notifications.
- `docs/REFRESH.md`: how to refresh the notes every two weeks.

### Known gaps
- Roughly a third of the detailed entries were marked `Partly verified` or `Unverified (Verify)` at this release; see 0.3.1 for the rerun.
- The index lists about 230 features; only the areas above have detailed entries.

## [0.2.0] - 2026-10-29

### Added
- `--grok` installer option: copies skills to `.grok/skills` for Grok Build, which reads `AGENTS.md` and `.grok/skills` (paths from third-party documentation, not yet confirmed against xAI's own docs).

## [0.1.0] - 2026-10-29

First public version.

### Added
- Skills: `flutter-project-profile`, `flutter-feature`, `flutter-review`, `flutter-new-project`, `flutter-estimate`.
- Cubit, Freezed, injectable and auto_route feature recipe and shared core types.
- `tool/install.dart`: copies skills to `.agents/skills` (and optionally `.claude/skills`, `.github/skills`) and maintains a managed block in `AGENTS.md`.
- Claude Code plugin and marketplace manifests.
