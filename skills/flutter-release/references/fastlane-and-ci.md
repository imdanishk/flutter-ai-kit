# Runbook: from the command line to Firebase, Play and TestFlight

Verified 2026-11-04 against Flutter's CD page and the Fastlane action pages unless a line says Unverified. The lane files in `assets/fastlane/` were checked for Ruby syntax only; they have not been run against a real project. Re-check pages older than about two months.

## 0. Once per project

1. Flavors exist and names match everywhere (Dart `--flavor`, Gradle flavor, iOS scheme, env file, Firebase app, store record). See `flutter-service-setup/references/environments-and-signing.md`.
2. Pin the Flutter version in `.fvmrc`. Lanes call `fvm flutter` when that file exists.
3. Release signing for Android is configured (`android/key.properties` read by Gradle; keystores outside the repo). iOS signing uses `match` with a private storage repo.
4. Create `Gemfile` in both `android/` and `ios/` (template: `assets/fastlane/Gemfile`), run `bundle install` in each folder, and commit `Gemfile` and `Gemfile.lock`. Always run lanes as `bundle exec fastlane <lane>`.
5. Copy the Fastfile templates to `android/fastlane/Fastfile` and `ios/fastlane/Fastfile`, `versioning.rb` into both folders and `Matchfile` into `ios/fastlane/`, create `Appfile` in each (package name or bundle ID, team IDs), and set `FLUTTER_ROOT` if the iOS scripts ask for it (Flutter's CD page says it is required for the iOS deploy scripts).
6. Create one ignored env file per flavor (`.env.development`, `.env.staging`, `.env.production`) from `assets/fastlane/env.example`. The lane templates load `.env.<FLUTTER_FLAVOR>` from the `fastlane/` folder in `before_all`, so `FLUTTER_FLAVOR` must be set on the command line. Never commit these files; the `.gitignore` in each `fastlane/` folder should ignore `.env*`, `*.json` credentials and `report.xml`.

## 1. Variables (names only; values live in env files or the CI secret store)

| Variable | Used by | Meaning |
|---|---|---|
| `FLUTTER_FLAVOR` | all lanes | flavor to build (`development`, `staging`, `production`) |
| `FLUTTER_TARGET` | all lanes | optional entry file, such as `lib/main_staging.dart` |
| `FIREBASE_APP_ID` | firebase lanes | Firebase App ID of that flavor and platform (not the package name) |
| `FIREBASE_TESTERS_GROUPS` | firebase lanes | group aliases, comma-separated |
| `FIREBASE_DISTRIBUTION_CREDENTIALS` | firebase lanes | path to the service-account JSON (CI: write it from a secret) |
| `PACKAGE_NAME` | Play lane | Android application ID of that flavor |
| `GOOGLE_PLAY_JSON_KEY_FILE` | Play lane | path to the Play service-account JSON |
| `APP_IDENTIFIER` | iOS lanes | bundle ID of that flavor |
| `BUILD_SCHEME`, `BUILD_CONFIGURATION` | iOS lanes | Xcode scheme and configuration for the flavor |
| `APPSTORE_TEAM_ID` | iOS lanes | Apple developer team ID |
| `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_CONTENT` | iOS lanes | App Store Connect API key (content base64-encoded) |
| `CERTIFICATE_GIT_URL`, `CERTIFICATE_GIT_BRANCH`, `MATCH_PASSWORD` | iOS lanes | match storage and passphrase |

## 2. Version and build number

- `pubspec.yaml` holds `1.4.0+27` (version name, then build number). Every upload needs a build number higher than the last one on that store.
- The lane templates derive the next build number from the target (the latest Firebase release, the highest version code across all Play tracks, or the latest TestFlight build) and add one, so it is always above what the store has; nothing is edited in `pubspec.yaml`. `release:patch|minor|major` also bumps the version name from the store's latest. With no `release:` only the build number rises. An explicit `build_number:` (and optional `build_name:`) overrides all of this, for example a CI run number.
- If the store has nothing yet, or the call fails, the lane falls back to the `pubspec.yaml` version and says so.
- The helper `versioning.rb` is plain Ruby and is tested in the kit repository (`ruby tool/test_versioning.rb`). The Fastlane calls that read the stores were not run.
- Write the chosen rule into the project profile so every developer and agent uses the same one.

## 3. Firebase App Distribution

```
cd android
FLUTTER_FLAVOR=development bundle exec fastlane firebase release_notes:"Fix login crash"
cd ../ios        # macOS only
FLUTTER_FLAVOR=development bundle exec fastlane firebase release_notes:"Fix login crash"
```

Needs: the plugin (`bundle exec fastlane add_plugin firebase_app_distribution`, run once per platform folder), a service account with the Firebase App Distribution Admin role, the Firebase App ID, a tester group alias. iOS uses ad hoc signing, so each tester's device must be registered in the profile (Unverified).

## 4. Google Play

```
cd android
FLUTTER_FLAVOR=production bundle exec fastlane playstore track:internal
FLUTTER_FLAVOR=production bundle exec fastlane playstore track:production   # lands as a draft; publish in the console
```

Needs: the first build uploaded manually; the service account invited in Play Console; `PACKAGE_NAME`; an upload keystore. The lane builds an App Bundle. Promotion beyond internal testing, the 12-tester rule and store listing requirements: `store-accounts-and-tracks.md`.

## 5. TestFlight

```
cd ios           # macOS only
FLUTTER_FLAVOR=production bundle exec fastlane testflight changelog:"What to test"
```

Needs: app record in App Store Connect; API key; match storage with an App Store profile for the flavor's bundle ID (see `ios-signing-and-match.md` for creating and fetching certificates); Xcode 26 or later. The lane builds, signs with the match profile and uploads without submitting for App Review. With `skip_waiting_for_build_processing: true` (the template default) the lane returns before Apple finishes processing, so external distribution must be done in App Store Connect or by a later lane.

## 6. CI/CD pipeline checklist

Templates for GitHub Actions (manual trigger only, secrets in per-flavor GitHub Environments, Flutter version read from `.fvmrc`) are in `assets/ci/github-actions/`; they were not run; action tags were checked to exist on 2026-11-05, behavior was not. For Bitbucket Pipelines, Codemagic or others, follow the checklist below in that service's syntax.

A pipeline should, in order: check out; install the pinned Flutter (read `.fvmrc`); install Ruby gems with Bundler in the platform folder; write secrets and signing inputs from the secret store (keystore decoded from base64, service-account JSON, `.env.<flavor>`, ASC key); run `flutter pub get`, localization and code generation; run analysis; call the lane. Production publishing should be a manual trigger. [Flutter CD](https://docs.flutter.dev/deployment/cd)

- Android CI also needs the Android SDK and `ANDROID_SDK_ROOT`; iOS CI pins Xcode and, for the build step, Flutter's page uses `flutter build ios --release --no-codesign --config-only` before the lane builds and signs.
- Secured variables are not available to pull-request builds until merged; do not print secrets; review any PR that touches secrets or pipeline files.
- Pass build-time values with `--dart-define`.
- Xcode Cloud is an alternative: it needs `ios/ci_scripts/ci_post_clone.sh` (made executable with `git add --chmod=+x`) that installs Flutter, runs `flutter precache --ios`, `flutter pub get` and `pod install`, and a Next Build Number set above the existing one for an existing app.
- **Drift check before trusting a pipeline.** Compare, by reading: lane names the pipeline calls vs lanes in the Fastfiles; env file name written vs name Fastlane loads; keystore properties file name written vs the one Gradle reads; Flutter version in the pipeline vs `.fvmrc`; flavors in the README vs flavors in the build files; the option names in README examples vs those the lanes read (for example `release_notes`, not `notes`). Report every mismatch.

## 7. Release checklist

Version and build number decided; changelog or release notes written; analyzer clean; flavors and bundle IDs checked against the target; fingerprints registered for the signing key that will be on users' devices; privacy manifest, data safety and age rating answers current; tester group or track named; production publishing confirmed by a person.
