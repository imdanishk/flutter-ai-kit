# Changelog

All notable changes are listed here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.11.2] - 2026-11-06

Changes from an independent read-only audit; each finding was checked against the files first, and the Fastlane parts against Fastlane's own source (2026-11-05).

### Fixed
- `versioning.rb`: `release:none` (the documented safe default) crashed the lane; it is now accepted, and the workflows' version input offers `none` instead of an empty string. A higher version in `pubspec.yaml` now wins over the store's (before, it was silently ignored); the tests cover both.
- iOS lane: the signing edit to `project.pbxproj` is undone after the build, so the working tree is clean afterwards.
- Both lanes: a missing `firebase_app_distribution` plugin now stops with a clear message instead of falling back and failing after a full build; the plugin step is in the setup list.
- `flutter-release`: agents are told never to pass `confirm:yes`, run `match nuke` or use `force` without approval in the conversation; low disk space is reported, not fixed by deleting `build/`; the final report covers the signing edit.
- CI: release workflows get `permissions: contents: read` and a note to limit secret-holding environments to main; the repo's release workflow passes the version through `env:`, checks its shape and runs only on main; `skills-ref` is pinned; Fastlane templates get a `ruby -c` step.
- Statements corrected: pull-request secret access depends on the CI service; the Play target-API extension date has passed; the Apple certificate-count claim and a `gcloud` format claim are marked unverified; the TestFlight changelog behaviour is stated from Fastlane's source.
- Cross-references in the feature notes pointed at files that do not exist; they now name `guides/...`.
- Matchfile (no `clone_branch_directly`, optional `MATCH_APP_IDENTIFIERS`, CI credential variables), `env.example`, `SECURITY.md`, `CONTRIBUTING.md`, `DECISIONS.md` and the marketplace description now match what the kit ships.
- Smaller: `flutter-git` formats only changed files; `flutter-service-setup` triggers on sign-in, Maps, push and billing problems only; the widget-test example defines its mock; README lists all skills.

### Added
- `tool/check.dart` fails when a skill names a `references/`, `guides/` or `assets/` file that does not exist.

## [0.11.1] - 2026-11-05

### Fixed
- `api-auth-paging-pitfalls.md`: the advice to replay the last sign-out event to late listeners could sign out the next session; it now says to read session state at start-up or clear the held event on sign-in.

## [0.11.0] - 2026-11-05

### Added
- `flutter-review`: `references/api-auth-paging-pitfalls.md`, a checklist of network, session, cubit, paging and cache bugs found by reading a small shared base package (200-only success checks, catch-alls that hide errors, 401/403 treated alike, parallel sign-out events, caches that outlive the account, a cache that stops a paged list from loading, search events that wipe filters), plus a short section in the review checklist. Read, not run: no Flutter SDK here and pub.dev was unreachable.
- `flutter-git`: machine-local and generated files that must not be committed, checked against Flutter's own project template `.gitignore` files (`flutter/flutter`, 2026-11-05).
- `flutter-feature`: a pointer to the pitfalls list for features that add API calls, tokens, paging, search or caches.

### Changed
- `data-and-platform-surfaces.md` and `auth-security.md`: the base-class note now states what was read and which bugs a copy would inherit.

## [0.10.5] - 2026-11-05

### Added
- `data-and-platform-surfaces.md`: the Result pattern read in full from Flutter's architecture docs (sealed `Ok`/`Error`, repositories return it, view models switch on it), and a short list of project-owned base-class ideas marked Unverified, taken from the README of a small public reference package.
- `index.md`: `fl_chart` and `chewie` rows with version, licence and date from a package index (pub.dev pages not opened).

### Changed
- Repo workflows use `actions/checkout@v7` (the v4 runs triggered GitHub's Node 20 deprecation warning).

## [0.10.4] - 2026-11-05

### Changed
- `flutter-testing`: pattern note from a real-project run (initialize localization when a failure path builds a localized message; a hand-written fake is fine when no mocking package exists).

## [0.10.3] - 2026-11-05

### Changed
- CI templates now use `flutter-version-file: .fvmrc` and the `jq` step is gone. Confirmed by reading `subosito/flutter-action`'s README, `action.yaml` and `setup.sh` (commit 4cab68c, 30 Apr 2026): `.fvmrc` is read with `jq -r .flutter`, and the file must hold an exact version, not a channel or range.
- Action majors raised to tags that exist: `actions/checkout@v7`, `actions/setup-java@v6`. Tag existence was checked; the workflows were still not run.

## [0.10.2] - 2026-11-05

### Added
- `social-login.md`: Facebook login setup (Android, iOS, web, code) and Sign in with Apple server-side steps. Both are second-hand and marked Unverified because Meta's, pub.dev's and Apple's pages could not be opened; items missing from the source (Android key hash, Live mode and App Review, deletion callback, Limited Login) are listed as unverified checks.
- `backend-handoff.md`: separate Sign in with Apple and Facebook rows, and a Facebook line on the per-environment sheet.

### Changed
- CI templates note the reported `flutter-version-file: .fvmrc` option for `subosito/flutter-action` as unconfirmed; the `jq` step stays.

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
