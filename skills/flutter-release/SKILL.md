---
name: flutter-release
description: Builds, signs and delivers a Flutter app to testers and stores with Fastlane and a CI pipeline - Firebase App Distribution, Google Play tracks and TestFlight - including iOS certificates and match, account setup, test tracks and the traps that stall first releases. Use when asked to set up release automation, ship a build, configure Fastlane, CI or iOS signing, or prepare a Play or App Store submission.
license: Apache-2.0
---

# Flutter release

Two layers, kept apart:

1. **Deployment lanes** (Fastlane): commands a developer can run on one machine to build a flavor and upload it.
2. **CI/CD** (Bitbucket Pipelines, GitHub Actions, Codemagic, any other): an optional pipeline that checks the code and calls those lanes on a branch, tag or manual trigger.

A Fastfile is not a pipeline, and a pipeline file does not prove deployment works. Test the lane locally first.

## Steps

1. **Say what the target is:** Firebase testers, a Google Play track, TestFlight, or a store submission. For each, note the platform: iOS builds and signing need macOS, so a Windows developer needs a Mac or a macOS CI runner for iOS.
2. **Read the project.** Look for `fastlane/` folders, `Gemfile`, pipeline files, `.fvmrc`, flavors in Gradle and Xcode, `key.properties`, and any release notes in the README. Extend what exists; do not replace it. If a pipeline and the Fastfiles disagree (a lane the pipeline calls that no Fastfile defines, an env file written under a different name, a keystore properties file named differently from the one Gradle reads), report it as drift and do not copy the pipeline as a working example.
3. **Check prerequisites** with the `flutter-service-setup` skill: flavors, one Firebase project per environment, fingerprints, keystores. Accounts, agreements, test tracks and review rules are in `references/store-accounts-and-tracks.md`. iOS certificates, profiles, `match`, devices and a new teammate's setup are in `references/ios-signing-and-match.md`. Open it before promising a date: some steps take days (identity verification, a 14-day closed test, Beta App Review).
4. **Follow the runbook** in `references/fastlane-and-ci.md` (command line to Firebase, Play and TestFlight, with the variable list and the pipeline checklist). Starting points for the lanes are in `assets/fastlane/` (Android and iOS Fastfiles, `Matchfile`, `versioning.rb`, `Gemfile`, `env.example`); copy and adapt them, and run them yourself only when the tools and credentials exist in the session.
5. **Report** what you changed, what you ran and what happened, what the developer or store owner must do by hand (console steps, secrets to add to CI, devices to register), and what you could not check.

## Run a release (when asked to ship a build)

- **Inputs.** Ask only for what the request did not give: flavor; platform; destination (Firebase, a Play track, TestFlight); version bump (`none` is the safe default and raises only the build number); optional release notes. Do not guess a production track.
- **Preflight, before any upload:** the flavor's entry point and Fastlane lane exist; the env and credential files exist (check that they exist, never read or print them); the working tree has no unexpected changes; enough free disk space for a build. If space is short, remove only generated output inside the project (`build/`) and ask before touching any shared cache or tool folder; never run broad deletes.
- **Order.** Android, then iOS. If Android fails, do not start iOS. If one platform succeeds and the other fails, report both and do not repeat the successful upload.
- **Do not change Fastfiles, version files, signing files or credentials** to make a deployment pass; report what is wrong instead. Do not stage, commit or amend anything.
- **Final report:** flavor and destination, the version name and build number each lane used, the artifact and upload result, warnings separate from failures, and anything the developer must do by hand.

## Rules

- Never publish to a production track, submit for App Review, or tag a release unless the developer asked for exactly that. Lanes default to draft or internal; production publishing is a deliberate manual step.
- Never print, log, commit or paste secrets: keystores, `key.properties`, `.p8` keys, service-account JSON, match passwords, env files. Examples use variable names only. Do not echo secret variables in scripts.
- One Flutter version in one file (`.fvmrc`); CI reads it. One name per environment everywhere.
- Every store upload needs a build number higher than the last one. Decide where the number comes from (CI run number, or the store's latest plus one) and write it down.
- Say plainly when a template or command was not run. The lane templates were checked for Ruby syntax only.
