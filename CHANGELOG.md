# Changelog

All notable changes are listed here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

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
