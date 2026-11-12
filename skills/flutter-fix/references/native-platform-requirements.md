# Native toolchain and platform requirements

Checked 2026-11-08; Flutter 3.50 lines added 2026-11-12. Sources: Flutter's `gradle_utils.dart` on the `stable` branch (the tool's own version tables), developer.android.com (Android Gradle plugin 9.5 release notes, 16 KB page sizes, edge-to-edge), kotlinlang.org Gradle compatibility table, Google Play target API page, developer.apple.com/news/upcoming-requirements, and docs.flutter.dev (Swift Package Manager, UIScene, edge-to-edge). These numbers change every few months: re-check the source named on each line before relying on one. *Unverified* marks what the pages read did not say.

## Android build toolchain

**Flutter 3.50** (released 2026-11-11 with Dart 3.14; Flutter's "What's new" post, read 2026-11-12) says a new project uses AGP 9.3.1, Gradle 9.5.0, Kotlin Gradle plugin 2.4.20 (verified by Flutter against these), Java 17 minimum, and `flutter.minSdkVersion` 24, `flutter.compileSdkVersion` and `flutter.targetSdkVersion` 36. The post does not give an NDK version, UIScene or 16 KB facts; keep the lines below for those. Other 3.50 notes from the post:
- AGP 9's new DSL needs every plugin to support Built-in Kotlin. Plugins that apply the Kotlin Gradle plugin by hand must migrate and declare `flutter: ">=3.44.0"` (the migration guide is listed under 3.44).
- Release-mode Android builds ignore `route`, `dart_entrypoint` and `cached_engine_id` from Intent extras and reject runtime engine flags such as `--dart-flags` supplied by Intent extras or with a prebuilt APK. Check any native code or tooling that launches Flutter with Intent extras.
- Building with Xcode 27 restores `flutter screenshot` on physical iPhones and iPads. Flutter no longer tests on Intel Macs and warns once; a future release will require Apple Silicon for iOS, macOS and Android builds. `flutter config --enable-macos-arm64-only` builds Apple Silicon-only macOS apps.
- Turning Swift Package Manager off now warns on every CLI command; the opt-out and later the CocoaPods fallback will be removed. CocoaPods trunk goes read-only in December 2026.
- `flutter config --enable-hcpp` opts into Hybrid Composition++ on Android 14 or later with Vulkan. *(Opt-in; not verified.)*

The table below is what the stable branch used before 3.50 (read 2026-11-08); use 3.50's values above for a project on 3.50:

What a new Flutter project used (stable branch, 2026-11-08):

| Item | Value |
|---|---|
| Gradle | 9.3.1 |
| Android Gradle plugin (AGP) | 9.1.0 |
| Kotlin Gradle plugin | 2.4.0 |
| minSdk / compileSdk / targetSdk | 24 / 36 / 36 |
| NDK | 28.2.13676358 |
| Java | 17 minimum (the tool warns and errors below 17) |

The newest versions Flutter's tooling knows about: AGP 9.2, Gradle 9.3.1, Kotlin plugin 2.4.0 (a source comment says these feed `flutter analyze --suggestions`; not run). Going past them is possible but unsupported by that Flutter version. Android's own page already documents AGP 9.5.0 (October 2026: Gradle 9.6.0, Build Tools 36.0.0, JDK 17, compileSdk up to 37), which is **ahead** of what the stable Flutter tool knows. Do not bump AGP to the newest on your own; use the version your Flutter release ships or documents.

Compatibility, from Flutter's tables:
- **Java and AGP:** Java 17 is required for AGP 8.0 to 9.2; AGP 7.0 to 7.4 works with Java 11.
- **AGP to minimum Gradle:** 8.0 to 8.1 needs 8.0; 8.2 needs 8.2; 8.3 needs 8.4; 8.4 needs 8.6; 8.5 to 8.6 needs 8.7; 8.7 needs 8.9; 8.8 needs 8.10.2; 8.9 and 8.10 need 8.11.1; 8.11 to 8.13 need 8.14; 9.0 needs 9.1.0; 9.1 needs 9.3.1.
- **Java to minimum Gradle:** Java 17 needs 7.3; Java 21 needs 8.4; Java 24 needs 8.14; Java 25 or 26 needs 9.1.0. For Java below 17, Gradle must stay at or below 8.14.100.
- **Kotlin plugin to Gradle and AGP** (kotlinlang.org): 2.4.0 to 2.4.10 supports Gradle 7.6.3 to 9.5.0 and AGP 8.5.2 to 9.1.0; 2.4.20 to 2.4.21 supports Gradle up to 9.7.0 and AGP 8.5.2 to 9.3.1; 2.3.20 to 2.3.21 supports Gradle up to 9.3.0 and AGP 8.2.2 to 9.0.0. Newer Gradle and AGP than the table's maximum may warn.
- Where they are set in a Flutter project: Gradle in `android/gradle/wrapper/gradle-wrapper.properties` (`distributionUrl`); AGP and the Kotlin plugin in `android/settings.gradle` or `settings.gradle.kts` (plugins block) *(typical locations, not verified on this read; the Android folder may differ in older projects)*. `flutter doctor -v` shows the Java version Flutter uses.

Upgrade order that follows from the tables: pick the Flutter version first; take its AGP, Gradle and Kotlin versions; change one of them at a time; build after each.

## Play Store rules that break uploads

- **Target API:** new apps and updates must target Android 16 (API 36) from 31 August 2026; the extension to 1 November 2026 has passed. Existing apps need API 35 or higher to stay available to new users on newer Android versions. Flutter's template already targets 36. [Target API page](https://support.google.com/googleplay/android-developer/answer/11926878)
- **16 KB memory pages:** apps targeting Android 15 (API 35) or higher must support 16 KB page sizes on 64-bit devices; from **1 February 2027** an update that does not cannot be released. Apps with only Java or Kotlin code already comply; **apps with native libraries must be rebuilt.** A Flutter app ships native libraries (the engine and any plugin with `.so` files), so check the built file instead of assuming: [page](https://developer.android.com/guide/practices/page-sizes)
  - Build side: AGP 8.5.1 or higher with uncompressed shared libraries (AGP 8.5 or lower needs `useLegacyPackaging = true`, which increases install size); NDK r28 or higher aligns by default; NDK r27 or lower needs the linker flags `-Wl,-z,max-page-size=16384` and `-Wl,-z,common-page-size=16384`; prebuilt libraries must be recompiled.
  - Check a built APK: Android Studio's Build > Analyze APK (Alignment column); `check_elf_alignment.sh app.apk`; `zipalign -v -c -P 16 4 app.apk` (Build-Tools 35.0.0 or higher; last line must read "Verification successful."); per library `llvm-objdump -p lib.so | grep LOAD` should show `align 2**14`; for a bundle `bundletool dump config --bundle=app.aab | grep alignment` should show `PAGE_ALIGNMENT_16K`.
  - Test: an emulator with a 16 KB Android 15 image, or a Pixel 8 or newer with the developer option; `adb shell getconf PAGE_SIZE` must print `16384`.
  - *Unverified:* which Flutter versions ship a 16 KB-aligned engine; which popular plugins do. Read the plugin's changelog or check the built file; if a plugin's library is not aligned, update or replace the plugin.
- **Edge-to-edge:** Android 15 enforces it for apps targeting API 35 or higher, and Android 16 removes the opt-out. Flutter made edge-to-edge the default on Android in 3.27. Apps that opted out with `android:windowOptOutEdgeToEdgeEnforcement` in `styles.xml` and `values-night/styles.xml` should migrate; add a `values-35` styles folder without that item so the attribute does not crash on Android 16 or later. After upgrading, check every screen for content under the status and navigation bars. [Flutter page](https://docs.flutter.dev/release/breaking-changes/default-systemuimode-edge-to-edge) The Flutter page on `SafeArea` and `MediaQuery` was not read.

## iOS build toolchain and App Store rules

- **Xcode 26 and the iOS 26 SDK** have been required for App Store Connect uploads since 28 April 2026. Uploaded iOS and iPadOS apps must target iOS 13 or later (listed as since 9 September 2026). The Xcode 27 upload date was not on the page read. [Apple](https://developer.apple.com/news/upcoming-requirements/)
- **UIScene lifecycle.** Apple: UIKit apps built with Xcode 27 (iOS 27 SDK) must use it or fail to launch (quoted by Flutter's page). Flutter support landed in 3.38 and is the default from 3.41, with automatic migration for an unmodified `AppDelegate`: run `flutter run` or `flutter build ios`; success prints `Finished migration to UIScene lifecycle`. A custom `AppDelegate`, or a Flutter older than 3.41, needs the manual steps (conform `AppDelegate` to `FlutterImplicitEngineDelegate` and register plugins in `didInitializeImplicitFlutterEngine`; add `UIApplicationSceneManifest` to `Info.plist` with `FlutterSceneDelegate`; do not touch `FlutterViewController` in `didFinishLaunchingWithOptions`). Plugins that use app lifecycle events must adopt `FlutterSceneLifeCycleDelegate`; add-to-app hosts need a `SceneDelegate`. [Flutter page](https://docs.flutter.dev/release/breaking-changes/uiscenedelegate)
- **Swift Package Manager.** On by default since Flutter 3.44; upgrading and running the app adds it. Plugins without SwiftPM support still use CocoaPods. Turn off for one project with `flutter: config: enable-swift-package-manager: false` in `pubspec.yaml`, or globally with `flutter config --no-enable-swift-package-manager`; the page says disabling "won't be allowed in the future". After raising Minimum Deployments in Xcode, run `flutter build ios --config-only`. The CocoaPods registry becomes **read-only on 2 December 2026**; CocoaPods stays in maintenance mode in Flutter. [Flutter page](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers)

## Using this in an upgrade

1. Write down the current Flutter, Gradle, AGP, Kotlin, Java, Xcode and iOS deployment target before changing anything.
2. Upgrade Flutter (see `upgrade-checklist.md`), then let the template versions above guide the native files; do not raise one native tool far ahead of the others.
3. Build a release APK or bundle and check 16 KB alignment; build iOS with the current Xcode and watch for the UIScene and SwiftPM messages.
4. List every native file you changed in the report.
