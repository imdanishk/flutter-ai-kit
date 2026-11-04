# Environments, flavors, fingerprints and signing

Verified 2026-11-04 on official pages unless a line says Unverified. Re-check pages older than about two months.

## One Firebase project per environment

- A Firebase project holds apps that are "platform variants of the same application from an end-user perspective"; apps in one project share Authentication, Firestore, Storage, Functions and one Google Analytics property (each app is a data stream); a project holds at most 30 apps. The page says production apps need "a clear development workflow, which usually involves using multiple environments" but does not name separate projects. [Firebase projects](https://firebase.google.com/docs/projects/learn-more)
- Recommendation (ours, inferred from the shared backends and the single Analytics property): create one Firebase project each for development, staging and production, and register that environment's Android and iOS apps in it. Then test users, test data, analytics events and crash reports stay out of production dashboards. Crashlytics is not described on that page; confirm how crashes are grouped before relying on this.
- Android package names and iOS bundle IDs must match the registered app exactly. For App Distribution the package name is case-sensitive and cannot be changed after registration. [App Distribution](https://firebase.google.com/docs/app-distribution/android/distribute-fastlane)
- The `mobilesdk_app_id` (Android) and `GOOGLE_APP_ID` (iOS) are not the package name or bundle ID. Tools such as App Distribution need the Firebase App ID, not the package name.

## Flavors

- Android: declare `flavorDimensions` and `productFlavors` in `android/app/build.gradle.kts`, with an `applicationIdSuffix` per flavor (for example `.staging`) so environments install side by side and can be registered separately. Run with `flutter run --flavor staging`, build with `flutter build apk|appbundle --flavor staging`. [Flutter flavors (Android)](https://docs.flutter.dev/deployment/flavors)
- In Dart, `appFlavor` (from `package:flutter/services.dart`) holds the `--flavor` value and is `null` when no flavor is passed: handle that case.
- App name per flavor: put `app_name` in `android/app/src/<flavor>/res/values/strings.xml` and reference `@string/app_name`. With AGP 9.0 or newer, setting `app_name` through `resValue()` fails the build ("contains custom resource values, but the feature is disabled"). Do not put `abiFilters` in a product flavor.
- The default release template signs `release` with the debug key until you add your own signing config.
- iOS needs a matching scheme and build configurations per flavor: see `https://docs.flutter.dev/deployment/flavors-ios` (not read when this was written; Unverified).
- Keep one name per environment everywhere: Dart flavor, Gradle flavor, iOS scheme, env file, Firebase app, store record, Fastlane variable. Mismatched names are the commonest cause of "the pipeline ran but deployed nothing".

## FlutterFire files

- `firebase login`, `dart pub global activate flutterfire_cli`, then `flutterfire configure` in the project: it creates a Firebase app per selected platform and writes `lib/firebase_options.dart` (identifiers, not secrets). Run it again when you add a platform or start using Crashlytics, Performance Monitoring, Realtime Database or Google sign-in. The page does not cover flavors. [FlutterFire setup](https://firebase.google.com/docs/flutter/setup)
- Per-flavor options (Unverified; run `flutterfire configure --help` for current flags): configure once per Firebase project into its own options file, and choose the file by `appFlavor` before `Firebase.initializeApp`.
- Per-flavor `google-services.json` and `GoogleService-Info.plist` (Unverified): Android reads `android/app/src/<flavor>/google-services.json` through the Google services Gradle plugin; iOS needs the right plist copied per build configuration. Confirm in the Firebase Android and iOS setup pages before wiring.
- Requirements stated on the setup page: Android API 24 or higher; iOS 15 or later; Cloud Messaging needs a physical iOS device, an APNs authentication key and Push Notifications enabled in Xcode.

## SHA fingerprints: why "works on my machine" happens

- Google sign-in and some Google services need the SHA-1 of the certificate that signs the build. [Google client auth](https://developers.google.com/android/guides/client-auth)
- Each developer's machine creates its own debug keystore (`~/.android/debug.keystore`, on Windows `%USERPROFILE%\.android\debug.keystore`, default password `android`). Two developers therefore have two different debug SHA-1 values, and sign-in that works for one fails for the other. The google_sign_in docs list "a missing or incorrect signing SHA for one or more build configurations" first among the causes, and say "works in one build but not another" is usually a signing or configuration mismatch.
- Get fingerprints:
  - debug: `keytool -list -v -alias androiddebugkey -keystore <path to debug.keystore>`
  - any variant: `./gradlew signingReport` in `android/` (lists SHA-1 and SHA-256 per variant)
  - a built file: `keytool -printcert -jarfile app.apk` (or `.aab`)
  - release keystore: `keytool -list -v -alias <alias> -keystore <path>`
- Two fixes; pick one and write it in the project rules:
  1. Register every developer's debug SHA-1 in the environment's Firebase app (and in any API key restriction). Simple; breaks again for each new developer or new machine. (That Firebase accepts several fingerprints per app is Unverified.)
  2. Use one shared debug keystore for the team (a debug key only signs test builds; Google's pages say to use debug certificates only for testing and never to publish an app signed with one), point `signingConfigs.debug` at it, and register its SHA-1 once. New developers copy the file. Keep release and upload keystores out of the repo.
- Add SHA-1 and SHA-256 for: debug, the upload key, and the Play app signing key (next section). The Cloud console expects colon-separated values; `gcloud` expects hex without separators.

## Play App Signing: three keys, three fingerprints

- With Play App Signing you sign uploads with an **upload key**; Google re-signs what users install with the **app signing key**, which you cannot retrieve and which does not change for the life of the app. A fingerprint from your own keystore is the upload key, not the key on users' devices; an uploaded AAB does not show the distributed fingerprint. [Play App Signing](https://developer.android.com/studio/publish/app-signing)
- Get the app signing and upload fingerprints (MD5, SHA-1, SHA-256) in Play Console under Release > Setup > App integrity (the page names it both "App integrity" and "App signing"; the menu label may differ).
- So a release build installed from Play uses the app signing key's SHA. Register it wherever the debug and upload SHAs are registered: Firebase (Google sign-in, phone auth), OAuth clients, API-key restrictions and the `assetlinks.json` file for app links and passkeys (inference from the pages; the signing page itself does not cover those uses). A release build sideloaded from your own keystore uses the upload SHA.
- A lost upload key can be reset in Play Console and does not affect the app signing key. Without Play App Signing a lost signing key means the app can never be updated.

## Keystore, secrets and one source of truth

- `android/key.properties` (store file, store password, key alias, key password) and every keystore stay out of source control; CI stores the keystore base64-encoded in an encrypted variable and decodes it at build time. [Flutter CD](https://docs.flutter.dev/deployment/cd)
- Name each file once. Gradle reads one properties file name; the pipeline must write exactly that name. Fastlane loads `.env.<FLUTTER_FLAVOR>`; the pipeline must write that name, not `.env`. When a document, a pipeline and a lane disagree, the lane or Gradle file that actually runs is the truth; fix the document.
- Pin the Flutter version in one file (`.fvmrc`) and make every other place read it. Two or three version files that disagree (version manager config, tool-versions file, CI image path) make local and CI builds differ silently.
- Build-time values go in with `--dart-define`; do not commit them.

## A working per-environment layout (from a team's project; a pattern, not an official page)

- Android: one `google-services.json` per flavor in `android/app/src/<flavor>/`; one keystore per environment referenced from `build.gradle.kts` signing configs; one Firebase-distribution service-account JSON and one Play-upload service-account JSON per environment next to the Fastfile; one `.env.<flavor>` per environment.
- iOS: one `GoogleService-Info.plist` per flavor under `ios/config/<flavor>/`, copied into the build by a script selected by scheme; Fastlane also holds `Appfile`, `Gymfile`, `Matchfile`, `Pluginfile` and a `.env.<flavor>` per environment.
- Check, for every environment, that each of these files exists on both platforms; a flavor present on Android but missing under `ios/config/` (or the reverse) is the commonest silent gap.
- Keystores, service-account JSON and `.env.*` files need to be ignored by git or kept in a private location the team controls; the folder layout alone does not show whether they are. Check `.gitignore` before the first commit.

## A per-environment file layout seen working in a production project

Not from official documentation; it shows the shape of a setup with four environments (development, staging, UAT, production). Copy the idea, not the names.

- `android/app/src/<flavor>/google-services.json`: one Firebase file per Android flavor in the flavor's own source folder (this answers the placement question above for Android; the official page was still not read).
- `android/app/`: one keystore per non-production environment, selected by that flavor's signing config. Check `.gitignore`: whether such files may be committed is a team decision, and a production or upload keystore is never committed.
- `android/fastlane/` and `ios/fastlane/`: one `.env.<flavor>` per environment, one Firebase Distribution service-account JSON per environment, one Play upload service-account JSON per environment, a `Pluginfile`, an `Appfile`, a README for the lanes, and a `.gitignore` that keeps every credential out of git. The iOS folder also has a `Gymfile` and a `Matchfile` (the lane templates here keep those options inline; splitting them is a style choice).
- `ios/config/<flavor>/GoogleService-Info.plist`: one plist per iOS flavor, and a shell script that picks the right one at build time (script content not seen: Unverified how it is wired into the Xcode build).
- Credential files are per environment on purpose: a leaked development credential then cannot publish production.

