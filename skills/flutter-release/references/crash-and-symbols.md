# Crash reporting, symbols and staged rollout

As of 2026-11-09: commands and rules below were read on the linked official pages on that date. Re-check them before relying on them. *Unverified* marks what the pages read did not say. None of this was run in a real project by the kit; the lane and pipeline templates do **not** pass obfuscation flags or upload symbols.

## Decide first: obfuscate or not

- Without `--obfuscate`, release stack traces from Flutter are already readable. Obfuscation hides names but is **not a security control**; do not keep secrets in the app (Flutter docs).
- With `--split-debug-info` alone (no `--obfuscate`), the app gets smaller and traces need symbols to be readable.
- Ask the team which they want. If they obfuscate, the symbols folder of **every released build** must be kept and uploaded; losing it makes that build's crashes unreadable.

## Build with symbols (Flutter, page last updated 2026-08-25)

```
flutter build appbundle --release --flavor <flavor> \
  --obfuscate --split-debug-info=build/symbols/<flavor>/<versionName>+<buildNumber>
```

- Supported targets include `apk`, `appbundle`, `ios`, `ipa`, `macos`, `linux`, `windows`. Web is not obfuscated (it is minified); Windows x64 writes a `.pdb` file that `flutter symbolize` does not read.
- Use a separate symbols folder per release; back it up (CI artifact or private bucket). Never commit it to a public repository.
- Do not use code that depends on names (`runtimeType.toString()` comparisons) in obfuscated builds; enum names are not obfuscated.
- Optional obfuscation map: add `--extra-gen-snapshot-options=--save-obfuscation-map=<file>.json` (some crash tools use it, see Sentry below).
- The lane templates run `flutter build ... --release` without these flags. To obfuscate Android, add the flags in `flutter_build` after the team agrees. For iOS the lane builds with Fastlane's `gym` after `flutter build ios --config-only`; *Unverified: how the obfuscation flags reach that Xcode build*, so run the iOS build once by hand with `flutter build ipa --obfuscate --split-debug-info=...` and compare.

## Read an obfuscated stack trace by hand

```
flutter symbolize -i <stack-trace-file> -d build/symbols/<...>/app.android-arm64.symbols
```

Pick the symbols file for the crashing platform and architecture (for example `app.android-arm64.symbols`). `flutter symbolize -h` lists options.

## Android shrinking and native symbols

- R8 code shrinking runs in Android release builds; Flutter's page contradicts itself on whether `--no-shrink` still works, so check on your Flutter version. A Play upload of an App Bundle includes the R8 mapping file automatically *(Unverified on the pages read; check the Play Console deobfuscation file in the release)*.
- **Native debug symbols** (for crashes in C/C++ libraries, including plugins): in the app module's Gradle file set `android.buildTypes.release.ndk.debugSymbolLevel` to `SYMBOL_TABLE` (function names) or `FULL` (also files and lines). With an App Bundle the file is included and uploaded with the bundle; the limit is 1.6 GB, so use `SYMBOL_TABLE` if `FULL` is too large. Libraries that arrive already stripped cannot be symbolized (the build logs a message at info level). [Android docs](https://developer.android.com/build/include-native-symbols) (updated 2026-09-21).
- Fastlane `upload_to_play_store` accepts `mapping` or `mapping_paths` (a `mapping.txt` or `native-debug-symbols.zip`) when you upload an APK or want to add files by hand. [Fastlane docs](https://docs.fastlane.tools/actions/upload_to_play_store/)

## Crashlytics (Firebase, page updated 2026-11-05)

1. `flutter pub add firebase_crashlytics firebase_analytics` (Analytics gives breadcrumb logs), then `flutterfire configure` (adds the Crashlytics Gradle plugin on Android), and rebuild.
2. Wire both error paths in `main()` after Firebase initializes: `FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;` and `PlatformDispatcher.instance.onError = (error, stack) { FirebaseCrashlytics.instance.recordError(error, stack, fatal: true); return true; };`.
3. **Obfuscated Android build:** upload the symbols before a crash is reported, from the project root: `firebase crashlytics:symbols:upload --app=<FIREBASE_APP_ID> <the --split-debug-info folder>`. Needs Firebase CLI 11.9.0 or later. The App ID is `mobilesdk_app_id` in `google-services.json`, not the package name; with flavors it differs per flavor.
4. **Apple platforms:** Flutter 3.12.0 or later with Crashlytics plugin 3.3.4 or later can generate and upload Flutter dSYM files automatically. *Unverified: the exact build-phase setup and whether it works with the lane's `gym` build; test with a forced crash.*
5. **Force a test crash** in a release-like build (not attached to the debugger) and confirm the readable trace appears; the page says to enable debug logging if nothing shows after five minutes.
6. Use the project's flavors: one Firebase project per environment, so dev crashes do not mix with production (see `flutter-service-setup`). Consider disabling collection in debug builds; ask the team.
7. Privacy: crash data and any user IDs you attach count in the Play Data safety form and Apple privacy labels.

## Sentry (alternative)

Sentry's docs recommend the `sentry_dart_plugin` (3.4.0, published 2026-05-28) as the upload method for iOS, Android and web. Steps from the docs page (no date shown): add it as a dev dependency; put the auth token in the `SENTRY_AUTH_TOKEN` environment variable (a CI secret, never in the repository); add a `sentry:` block to `pubspec.yaml` with `project` and `org`; build with `--obfuscate --split-debug-info=<dir> --extra-gen-snapshot-options=--save-obfuscation-map=build/app/obfuscation.map.json` and set `dart_symbol_map_path` to that file (plugin 3.2.0 or later); run `dart run sentry_dart_plugin` after the build. Environment variables take precedence over `pubspec.yaml`. Uploading debug files is recommended even without obfuscation.

## Staged rollout (after internal and closed testing, when a person decides to go to production)

- **Google Play** (Play Console help): staged rollouts apply to **updates only, not a first publication**. You choose a percentage; it **does not rise by itself**, so a person raises it (Releases, Manage rollout, Update rollout). **Halt rollout** stops new users from receiving the version; those who have it keep it. There is no rollback; ship a new release with a higher version code that fixes the problem. Resuming reaches the same set of users. Countries cannot be removed once a rollout starts.
- **Fastlane:** `rollout` takes a fraction (setting 1 completes it) and `release_status` takes `completed`, `draft`, `halted` or `inProgress` (option text read 2026-11-09). The kit's lane leaves non-internal tracks as drafts; a staged production release is a deliberate step the developer asks for. *Unverified: combining `release_status: inProgress` with `rollout` from the lane; try it on a test app first.*
- **App Store** (App Store Connect help): phased release is chosen when you submit a version update (not for the first release). It applies to automatic updates only: 1%, 2%, 5%, 10%, 20%, 50%, 100% over 7 days; anyone can still download the update manually at any time. You can pause (30 days in total across any number of pauses) or release to all users early. The Account Holder, Admin or App Manager role is needed.
- **Watch before widening:** crash-free users and sessions in Crashlytics or Sentry, new error groups, store reviews, support messages. Widen only after a person has looked. Decide in advance what number makes you halt.

## Release checklist additions

Symbols folder or mapping file saved for this exact build number; symbols uploaded to the crash tool; a forced crash showed a readable trace on a release-like build; the crash tool's environment matches the flavor; privacy answers include the crash tool; staged-rollout percentage and halt criteria written down before production is touched.
