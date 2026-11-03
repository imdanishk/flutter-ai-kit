# Changelog

All notable changes are listed here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

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
