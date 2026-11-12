# Changelog

All notable changes are listed here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.19.2] - 2026-11-12

Fixes from a real run of a project created with the new-project skill (Flutter 3.50.0 pin): `pub get`, build_runner, format and analyze passed and the app ran on an Android 15 emulator.

### Changed
- `dart run build_runner build` no longer includes `--delete-conflicting-outputs` in the new-project skill, the Ferry recipe and the CI templates: the run printed that the option was removed and ignored.
- New-project step 7: `flutter run -d <device> --no-resident` for shells with a time limit.
- Debugging playbook: tool messages seen in the trial runs (kernel binary version, missing env value, private git host key, removed flag).

## [0.19.1] - 2026-11-12

Fixes from four trial runs on real Cubit/Freezed/injectable apps (three current, one old) by a developer with Flutter installed. In all four the profile matched the code, the feature followed each project's own base classes and generated-code pattern, and the review ran read-only; the plan skill was not exercised (no ticket was supplied).

### Changed
- AGENTS block: never print, copy or recover secrets, including from git history (one run restored old environment files from git history after code generation failed on missing values).
- `flutter-feature`: when generation or analysis cannot run, do not recreate or recover env files, do not hand-write generated files, give the exact command for the developer, use `flutter analyze --no-pub` when packages must not change (a plain `flutter analyze` resolved and downloaded packages in one run), and stop on a private git dependency that cannot be cloned.

## [0.19.0] - 2026-11-12

### Added
- `flutter-fix/references/performance-and-app-size.md`: measuring in profile mode on a device, the performance overlay and frame budget, common causes (build cost, lazy lists, `saveLayer`, opacity and clipping, animations), `Isolate.run` and its limits, DevTools memory and leaks, measuring app size (`--analyze-size`, Play and App Thinning estimates), reducing it (`--split-debug-info`, deferred components), and how to report a before and after. Read from the Flutter docs on 2026-11-12; what the pages did not say (start-up, `--split-per-abi`, WebP, `cacheWidth`) is marked Unverified.

### Changed
- `flutter-fix` now also covers slow, janky or oversized apps; `flutter-review` has a performance check; the release notes point to the size check.

## [0.18.0] - 2026-11-12

State management and routing recipes, with `flutter_bloc` (Cubit or Bloc) and Riverpod as the focus. Read from the packages' official docs on 2026-11-12; the Dart in the recipes was not compiled.

### Added
- `flutter-feature/references/bloc-plain-recipe.md`: a feature slice for `flutter_bloc` without Freezed or injectable (Equatable state, event transformers from `bloc_concurrency`, `RepositoryProvider`, one-off effects, forms).
- `flutter-feature/references/go-router-recipe.md`: go_router setup, `go` versus `push` and the lost-state bug, `StatefulShellRoute` tabs, redirects and sign-in, type-safe routes, pitfalls, and the move to 18.

### Changed
- `flutter-review`: go_router and plain Bloc checks added to the stack-specific list.

## [0.17.0] - 2026-11-12

Flutter 3.50 and Dart 3.14 were released on 2026-11-11. Facts were read from Flutter's "What's new" post, the Dart 3.14 announcement, the breaking-changes page and the `material_ui` migration guide; nothing was run on 3.50.

### Added
- `flutter-fix/references/native-platform-requirements.md`: Flutter 3.50 template values (AGP 9.3.1, Gradle 9.5.0, Kotlin plugin 2.4.20, Java 17, SDK 24/36/36), Built-in Kotlin for plugins, restricted Intent extras and engine flags in Android release builds, Xcode 27 and Apple Silicon notes, SwiftPM and CocoaPods changes.
- `flutter-fix/references/upgrade-checklist.md`: the Material and Cupertino move to `material_ui` and `cupertino_ui` (steps, localization delegates, compatibility bridge, third-party limits), `dart migrate`, legacy web library deprecation, smaller 3.50 breaking changes.
- AI guide: Genkit Dart 1.0 (`genkit`) and the new MediaPipe package, with what the pages did not say marked Unverified.

### Changed
- Localization recipe, theme reference and new-project skill note the `material_ui` imports on 3.50.

## [0.16.1] - 2026-11-12

Fixes from two real runs of the skills by a developer on Flutter 3.44.9 (Windows, OpenCode, Wonderous, two different models). Each report finding was checked against the files first; one was rejected (the skills named `flutter-project-setup`, `flutter-testing-setup` and `replace-with-skill-name` belong to another repository, not this kit).

### Changed
- `flutter-fix`: when the app cannot be run, a bug cause is labelled "found by reading, not reproduced" with the other plausible causes, and code changes only with the developer's agreement (the two models found different causes). The upgrade checklist now finds held-back and companion packages first (`get_it` with `get_it_mixin`, SDK-pinned `intl`) and stops after the plan on a plan-only request.
- `flutter-plan`: the effort step says what to do without `flutter-estimate`; a path the developer names is written, not just offered.
- `flutter-review`: reviews named files with no diff; a check for other state patterns (`ValueNotifier`, `ChangeNotifier`, get_it); the localization recipe is opened when installed.
- `flutter-store-assets`: an existing logo or icon wins over a new master; clear fallbacks without an image tool or a runnable app.
- `flutter-design`: case C asks what the screen must show before inventing content.
- README: open the project folder itself as the agent's workspace so the skills are listed.

## [0.16.0] - 2026-11-12

Adds localization and fixes gaps found by running the plan, fix, design, store-assets and profile skills by hand against a real open-source app (Wonderous, MIT: get_it with `ValueNotifier`, go_router, no BLoC). Nothing was built or run: Flutter and Dart were not available, so the trial read the code, measured the icon files and followed each skill's steps.

### Added
- `flutter-feature/references/localization-recipe.md`: gen-l10n setup and `l10n.yaml`, ARB placeholders, plurals and select, number and date formats, rules for code, right-to-left, Android per-app language and localized app name, iOS localizations, and per-language store listing limits and screenshots. Dated 2026-11-11, with unverified items marked.
- `flutter-plan`: extra paths to check when data syncs between devices (first sign-in merge, conflicts, sign-out, migration of existing local data).

### Changed
- `flutter-project-profile`: the exemplar and state-handling questions no longer assume cubits and a domain/data/presentation split (the trial app has only `logic` and `ui` folders).
- `flutter-store-assets`: keep the project's own icon tool (the trial app used `icons_launcher`); localized screenshots pointer.
- `flutter-fix` upgrade checklist: what to do when Flutter or Dart cannot be run.
- `flutter-review` and `flutter-feature` checklists mention plurals built in code and left/right values in right-to-left apps.
- Feature-notes localization row points to the recipe.

## [0.15.0] - 2026-11-09

Closes the three gaps the 0.14.0 coverage audit left open. Facts were read on official pages on 2026-11-09; anything the pages did not say is marked Unverified in the files.

### Added
- `flutter-feature-notes/references/guides/ai-features-in-apps.md`: where the model runs (Firebase AI Logic, own backend, on-device options), no provider keys in the app, App Check and its enforcement dates (2026-11-02, delay possible to 2027-01-21), per-user limits and cost, streaming and chat UI, output as untrusted input, Apple 5.1.2(i) and 1.2 and Google Play's AI-generated content policy, the OWASP LLM Top 10 (2025) risks that matter in a mobile app, and how to evaluate AI features (golden set, code and model grading, when to run it, metrics).
- `flutter-release/references/crash-and-symbols.md`: `--obfuscate --split-debug-info` and `flutter symbolize`, R8 and Android native debug symbols, Crashlytics and Sentry symbol uploads, Play staged rollout and halt, App Store phased release, and release checklist additions. Linked from the flutter-release skill.
- `flutter-release/assets/ci/github-actions/pr-check.yml`: secret-free pull-request check (format, analyze, tests that already exist). Not run against a real repository.

### Changed
- Feature-notes index: AI rows point to the new guide; `flutter_gemma` is marked discontinued (its page points to `flutter_edge_ai`). The GraphQL entry points to the Ferry recipe.
- Known gaps in `docs/DECISIONS.md` updated; decision 18 added.

## [0.14.0] - 2026-11-09

### Added
- `flutter-feature/references/graphql-ferry-recipe.md`: Ferry setup, code generation, client and cache, fetch policies, mapping `OperationResponse` to the project's `Result`, an auth link with refresh, and what to ask the backend owner. Read from Ferry's own repository and docs (commit of 2026-10-27), the `gql` links and an auth-link example, and pub.dev; unverified points are marked. It records that Ferry's stable pub.dev releases date from January 2025 while main carries newer prereleases.
- GraphQL section in `flutter-review/references/api-auth-paging-pitfalls.md`.
- `flutter-fix/references/native-platform-requirements.md`: dated tables for the Gradle, Android Gradle plugin, Kotlin and Java versions in Flutter's own tooling and the Android and Kotlin compatibility tables; Play's target API (36) and 16 KB page rule with the 1 February 2027 date and the ways to check a build; edge-to-edge; Xcode 26 and iOS deployment target rules; UIScene (Flutter 3.38 and 3.41, Xcode 27); Swift Package Manager (default from 3.44) and the CocoaPods read-only date. It replaces the unverified native stub in the upgrade checklist.
- `flutter-plan` lists acceptance criteria and open questions first when the input is a requirements document or ticket.

### Changed
- The `AGENTS.md` block moved to `skills/flutter-project-profile/assets/AGENTS.block.md` so the skills-only and plugin installs can offer it too (the profile skill asks first). It gained three working rules: read before editing and ask or state an assumption; make the smallest change; say what was and was not checked. The rules restate the guidelines of `multica-ai/andrej-karpathy-skills` in the kit's own words (decision 16).
- Gaps found by the coverage audit (AI features and evals, release symbols and crash reporting, pull-request CI) are listed in `docs/DECISIONS.md`.

## [0.13.1] - 2026-11-08

Changes from a final review of the new skills and an independent read-only audit of the whole kit. Each finding was checked against the files first; one audit doubt (Apple's iPhone screenshot sizes) was re-read on Apple's page and the kit's numbers were correct.

### Fixed
- Installer: an `AGENTS.md` with a start marker but no end marker (or the markers in the wrong order) made the next run delete text between them. It now stops before writing anything and says what to fix; CI tests this.
- `slicePage` in the shared core threw for a negative limit; it now returns an empty page (test added).
- `flutter-release`: one line told the agent to run lanes whenever credentials exist, against its own rule to upload only when asked to ship; it now says to check without uploading and run an uploading lane only on request.
- Android release workflow template no longer passes release notes the Play lane ignores; both workflow templates gained a `concurrency` group so two runs cannot pick the same build number.
- The release workflow now runs the whole `validate` workflow first and publishes only if it passes.
- The feature-notes reminder now also checks `references/guides/` (each guide carries an `As of` date); stale limit is 30 days in the workflow, `docs/REFRESH.md` and the skill.
- Contradictions: README no longer says the kit never runs your app (new-project asks first); `.fvmrc` advice no longer says "commit" for the agent; `--grok` listed in decision 1; decision on Fastlane names matches the 0.11.3 check; README names the skills not yet tried on a real project.

### Changed
- The `AGENTS.md` block is shorter (the long skill list is gone, since agents pick skills by their descriptions) and says that a small fix or question does not need the profile skill and that nothing is uploaded, published or pushed unless asked. The profile skill shows its result and writes `AGENTS.md` after the developer agrees, unless they asked for the profile.
- Trigger wording: `flutter-fix` (no "clean up" or "migrate"), `flutter-feature-notes` (no everyday words like sign-in or maps; read one section, not a whole file; at most about five pages), `flutter-feature` hands visual work to `flutter-design`, `flutter-estimate` and `flutter-plan` no longer hand work back and forth, `flutter-fix` points to `flutter-release` and `flutter-service-setup`.
- `tool/check.dart` also checks that README mentions every skill, that files under `references/` and `assets/` are used, that more kinds of referenced files exist, an exact changelog heading and a size cap on the `AGENTS.md` block.
- `docs/PUBLISHING.md` was a second copy of `CONTRIBUTING.md` "Releasing" and was removed.
- `flutter-design` asks whether the app uses one look on both platforms or platform-adaptive widgets.

## [0.13.0] - 2026-11-08

### Added
- `flutter-plan`: screens, user flows and journeys as Mermaid diagrams (the three example diagrams were rendered with `mmdc` to check the syntax), an ordered build plan of small slices for a whole app or one feature, a plan template with acceptance checks and a blockers table, and slicing and ordering rules.
- `flutter-fix`: three modes (bug or crash by root cause, behaviour-preserving refactor, upgrade). The debugging playbook carries the official common-errors list and the DevTools tool list; the upgrade checklist carries `dart pub outdated` columns, `dart pub upgrade` flags, FVM commands and the Flutter breaking-changes index, all read on 2026-11-08. Native toolchain advice is marked unverified.
- Decision 15 in `docs/DECISIONS.md`.

### Changed
- Design references: Mobbin, ASO Shots and four third-party design skill sets were reviewed (read, not run); verdicts and licences are in `design-sources.md`, an optional ASO Shots route is in `screenshots.md`, and a short list of mobile patterns was added to `states-and-accessibility.md` in the kit's own words. Nothing was copied or installed.
- The `AGENTS.md` block lists `flutter-plan` and `flutter-fix`. README table, lifecycle and the name-collision note are updated.

## [0.12.0] - 2026-11-08

### Added
- `flutter-design` (on request only): four cases (design provided, design changed, new feature in the existing look, no design), where design values live in a Flutter theme, how to bring a design in (Figma MCP, images, running app), states and accessibility checklist. Flutter facts were read from docs.flutter.dev and api.flutter.dev on 2026-11-08; the Figma and Dart MCP pages do not mention Flutter output or screenshot tools, and the skill says so.
- `flutter-store-assets` (on request only): Google Play and App Store graphic sizes with sources and dates, Android adaptive icon and iOS icon rules, `flutter_launcher_icons` option names, screenshot capture and framing guidance, Fastlane `supply` and `deliver` folder layouts. Apple's screenshot page was truncated in the Watch section and Google's icon-design page was not read; both are marked.
- Decisions 13 and 14 in `docs/DECISIONS.md`.

### Changed
- The `AGENTS.md` block lists the two new skills as on-request only. README lists them in the skill table and lifecycle.

## [0.11.3] - 2026-11-07

### Changed
- Fastlane templates: every action and option the Android and iOS lanes use (`upload_to_play_store`, `google_play_track_version_codes`, `app_store_connect_api_key`, `gym`, `match`, `register_device`, `latest_testflight_build_number`, `upload_to_testflight`, `update_code_signing_settings`) was checked against Fastlane's source (2026-11-05) and exists with those names; the match profile-name variable and gym's `app-store` and `ad-hoc` export methods are confirmed too. The `firebase_app_distribution` plugin actions are not in that source and stay unconfirmed.
- `docs/PUBLISHING.md` rewritten as the current release process (one-time setup is done).

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
