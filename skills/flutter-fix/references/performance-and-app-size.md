# Performance and app size

As of 2026-11-12: rules below were read on the linked Flutter and DevTools pages on that date (the docs say they reflect Flutter 3.50; some pages show older "covers 3.47" notes). Re-check before relying on them. *Unverified* marks what the pages read did not say. Lines marked *Kit suggestion* are practice, not read on an official page.

Measure first. Never change code for performance on a guess, and do not report an improvement without a before and after number from the same device and build mode.

## 1. Measure speed and jank

- **Profile mode on a physical device, ideally the slowest one your users reasonably have.** Debug mode, simulators and emulators are "generally not indicative" of release behaviour: debug has expensive asserts and compiles Dart just in time (pauses can look like jank), profile and release are ahead-of-time. Run `flutter run --profile` (VS Code: `"flutterMode": "profile"` in `launch.json`; Android Studio: Run, Flutter Run main.dart in Profile Mode). [Profiling page](https://docs.flutter.dev/perf/ui-performance) (updated 2026-10-28)
- **Performance overlay:** press `P` in the `flutter run` session, or use the DevTools Performance view button. Top graph is the raster ("GPU") thread, bottom is the UI thread; each shows the last 300 frames; a red bar is a missed frame.
- **Frame budget:** about 16 ms per frame at 60 Hz. The best-practices page (updated 2026-10-14) says 16 ms for building plus 16 ms for rendering, and 8 ms each for low latency or 120 Hz.
- **Read the graphs:** red in the **UI** graph means the Dart code is too expensive (profile the Dart code first, even when both are red); red in the **raster** graph only means the scene is cheap to build but expensive to draw.
- **Animations:** slow them down in the Flutter inspector (5x) to see which part janks. First-run-only jank on mobile: the docs say to use the default renderer, Impeller.
- On a request like "the app is slow", ask which screen, which device and OS, which build mode, and what exactly is slow (start-up, scrolling, an animation, a tap response). Ask at most three questions.

## 2. Common causes and fixes (from the best-practices page)

- **`build()` cost:** avoid repetitive or costly work in `build()`; avoid one huge `build()`, split into widgets by how they change; call `setState()` as low in the tree as possible; prefer a `StatelessWidget` over a helper function for reusable UI; do not override `operator ==` on widgets (O(N²)), except cheap leaf widgets.
- **Lists and grids:** use the lazy builder constructors (`ListView.builder`, `GridView.builder`, slivers); `Column`/`ListView` with a concrete child list builds everything.
- **Intrinsic passes:** layouts that ask every child for its size are costly (DevTools "Track layouts" shows them); give cells a fixed size.
- **`saveLayer`:** excessive calls cause jank. Triggers named on the page: `ShaderMask`, `ColorFilter`, `Chip` with certain alpha, `Text` with an overflow shader, `Clip.antiAliasWithSaveLayer`. The page suggests asking whether the effect is needed, applying it to one element instead of a group, and avoiding opacity, clipping or shadows high in the tree.
- **Opacity and clipping:** use `Opacity` only when needed; draw simple shapes or text with a semi-transparent colour if nothing overlaps; use `FadeInImage` or `AnimatedOpacity` for fades; clipping is costly, so use `borderRadius` on a decoration for rounded corners instead of a clip.
- **Animations:** with `AnimatedBuilder`, pass the static subtree as `child` so it is not rebuilt each tick; avoid clipping in an animation (pre-clip the image); `RepaintBoundary` for static content that is faded, rotated or transformed, and cache images only where needed (raster cache uses GPU memory).
- **Strings:** build long strings with `StringBuffer`, not repeated `+`.
- **Heavy work off the UI thread:** parsing or decoding large files, compressing media, filtering large lists, reading a large local database. Use `Isolate.run` (callback with exactly one required unnamed argument; the page's example decodes a 20 MB JSON file) or `compute` (same on mobile and desktop; on web it runs on the main thread because web has no isolates). Spawned isolates cannot use `rootBundle` or widgets; plugins in a background isolate need `BackgroundIsolateBinaryMessenger.ensureInitialized` with a `RootIsolateToken`; messages are copied unless immutable, and `Isolate.run` returns its result by `Isolate.exit` (ownership transfer). [Isolates page](https://docs.flutter.dev/perf/isolates) (updated 2026-07-31)
- *Kit suggestion, by state library:* rebuild only what changed: `BlocSelector` or `buildWhen` for Bloc, `ref.watch(provider.select(...))` for Riverpod, one `BlocBuilder` per independent part of the screen rather than one at the top. Do not put `BlocProvider`, controllers or futures creation inside `build`.
- *Kit suggestion:* decode images at display size (`cacheWidth`/`cacheHeight` or a resized asset). *Unverified: the pages read did not mention these parameters.*

## 3. Memory and leaks

DevTools Memory view (updated 2026-07-31, for DevTools 2.23.0): Profile Memory (allocation by class; refresh on GC), Diff Snapshots (snapshot before and after using a feature, then diff), Trace Instances (which code allocates a class). Rules from the page: call `dispose()` on disposable objects when no longer needed; never keep a `BuildContext` in a `State` field; a closure that outlives the widget can keep large objects alive, so capture the value you need (such as `Theme.of(context)`), not the context. *Kit suggestion:* the common leaks in app code are undisposed controllers, focus nodes, stream subscriptions, animation controllers and listeners on a long-lived notifier; the `flutter-review` checklist covers them.

## 4. Measure app size

Debug and default release builds do not show download size; the stores re-process the upload per device. [App size page](https://docs.flutter.dev/perf/app-size) (updated 2026-05-05)
- **Android estimate:** `flutter build appbundle`, upload to Play Console, read Android vitals, App size (computed for an XXXHDPI arm64-v8a device).
- **iOS estimate:** `flutter build ipa --export-method development`, open the archive in Xcode, Distribute App, Development, App Thinning "all compatible device variants", Strip Swift symbols; the export holds `App Thinning Size Report.txt`. Exact size: upload a release IPA to App Store Connect (needs the account; ask before uploading anything).
- **Breakdown:** `flutter build apk --analyze-size` (also `appbundle`, `ios`, `linux`, `macos`, `windows`). It prints a summary by category and writes a `*-code-size-analysis_*.json`; open it with `dart devtools`, Open app size tool (tree and treemap, up to function level for Dart AOT code; two files can be compared). On iOS this gives a `.app`, so relative sizes, not download size.
- **Record** the size of each release (build number, tool, number) so growth is visible. *Kit suggestion.*

## 5. Reduce app size

From the page: build release with `--split-debug-info` (see `flutter-release/references/crash-and-symbols.md` for the symbols you must then keep); remove unused resources; minimize resources imported from libraries; compress PNG and JPEG; guard platform-specific code with `Platform` checks from `dart:io` (the compiler removes unreachable branches in release builds of other platforms).
- **Deferred components** (Android and web only; the page does not mention iOS; updated 2026-09-29): load code and assets on demand with deferred imports and Play's delivery. Needs an Android App Bundle uploaded to Play; the build validator fails the first time and writes setup files; loading units go in `deferred_components_loading_units.yaml` (commit it); debug mode treats them as normal imports; code changes need a new build number. It is a large, native-touching change, so ask first and plan it as a slice.
- *Unverified, the pages read did not say:* `--split-per-abi` for APKs, WebP conversion, icon tree-shaking flags, and which popular packages are heavy. Check `--analyze-size` output instead of assuming; remove a package only after the report names it.
- Adding a package for a small feature is the usual cause of growth: ask whether the platform or the SDK already does it.

## 6. Start-up time

*Unverified: the pages read did not cover start-up.* *Kit suggestion:* measure cold start in profile mode on a real device; do work before the first frame only if the first screen needs it; initialize SDKs lazily or in parallel; keep `main()` free of network calls.

## 7. Report

State the device, OS and build mode; the number before and after; what changed and why that cause (the evidence: overlay graph, DevTools frame, size report line); what was not measured; and what else looked costly but was left alone. "Feels faster" is not a result.
