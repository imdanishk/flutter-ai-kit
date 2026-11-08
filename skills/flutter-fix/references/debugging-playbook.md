# Debugging playbook

Sources read 2026-11-08: docs.flutter.dev/testing/common-errors, docs.flutter.dev/tools/devtools/overview and docs.flutter.dev/deployment/obfuscate. Lines marked *Not verified* are general practice, not taken from an official page.

If the official Flutter and Dart skills are installed, `flutter-fix-layout-issues`, `dart-fix-runtime-errors` and `dart-resolve-package-conflicts` may cover narrower cases (their contents were not read); use them for those and this playbook for the surrounding steps.

## 1. Pin down the problem

Write down before touching code:
- Exact error text and the full stack trace (the first error in a log, not the last: later errors are often side effects).
- Steps to reproduce, expected versus actual.
- Platform and OS version, device or simulator, debug, profile or release build (a red screen appears in debug and profile; release shows grey).
- `flutter --version` (through FVM if pinned) and whether the bug began after a change (last good commit, upgrade, new package). *Not verified:* `git bisect` is the quick way to find the commit when it did.

## 2. Find the cause

Work from evidence, one hypothesis at a time. Change one thing, observe, then keep or revert.

| Symptom | Look at |
|---|---|
| Red or grey screen, exception in the console | The first exception in the log; the widget named in it |
| Layout wrong or overflow | Inspector in DevTools (widget tree, layout), the constraints given by the parent |
| UI does not update | Is state replaced with a new object? Is the right widget listening? Is a status shared by two operations? |
| Stuck on loading | The error path: does every failure leave the loading state? Was a request never awaited or never completed? |
| Works in debug, fails in release | Obfuscation or tree shaking, missing platform permissions or config only used in release, different API keys or flavour *(not verified)* |
| Crash after `await` | Use of `BuildContext` after the await without `context.mounted`; state emitted after close; a disposed controller |
| Slow or janky | Performance and CPU Profiler in DevTools, in profile mode on a real device *(profile mode on a device: not verified on this read)* |
| Memory grows | Memory tool: what is retained; undisposed controllers, subscriptions and timers |
| Request fails or returns wrong data | Network tool and Logging in DevTools: status, headers, body; compare with the API contract |
| Build fails (Gradle, Xcode, pods) | The first error in the build log; versions of the Android and iOS toolchains against what the Flutter version supports *(not verified; check the Flutter release notes and migration guides)* |

DevTools tools listed on its overview page: Flutter Inspector, Performance, CPU Profiler, Memory, Network, Debugger, Debug Console, Logging, App Size, Deep Link Validation, and extensions. It can be launched from VS Code, Android Studio or IntelliJ, or the command line (see docs.flutter.dev/tools/devtools); the exact command is on that page, not read here.

## 3. Common Flutter errors (from the official page)

| Message | Cause | Fix the page gives |
|---|---|---|
| A solid red or grey screen | An uncaught exception or rendering error such as an overflow | Find the underlying error and handle it where it occurs |
| `A RenderFlex overflowed…` | A `Column` or `Row` child is not size-constrained | Wrap the child in `Expanded` or `Flexible` |
| `RenderBox was not laid out` | Usually a side effect of an earlier rendering error | Fix the primary error that appeared first |
| `Vertical viewport was given unbounded height` | A `ListView` or `GridView` directly inside a `Column` with no height | Wrap in `Expanded`, or give a height with `SizedBox` or `Flexible` |
| `An InputDecorator...cannot have an unbounded width` | A `TextField` in a `Row` with no width constraint | Wrap in `Expanded` or `SizedBox` |
| `Incorrect use of ParentData widget` | A widget is not inside the ancestor it needs | `Flexible`/`Expanded` inside `Row`, `Column` or `Flex`; `Positioned` inside `Stack`; `TableCell` inside `Table` |
| `setState called during build` | `setState`, directly or through something like `showDialog`, runs during `build` | Do not trigger dialogs from `build`; show them from an event or a route |
| `The ScrollController is attached to multiple scroll views` | Several scrolling widgets share one controller (more common on web and desktop) | Use `PrimaryScrollController` |

The page gives no fix for the generic red or grey screen beyond finding the underlying error.

## 3b. Release builds and obfuscated stack traces

If the build used `--obfuscate`, the trace shows meaningless names. Symbols are written to the directory given to `--split-debug-info` (for example `out/android/app.android-arm64.symbols`; the file name carries platform and architecture). The Flutter page says to back these files up after every obfuscated build; without them old traces cannot be read. Decode a trace with:

```
flutter symbolize -i <stack-trace-file> -d <symbols-file>
```

Facts from the page: obfuscation only works on release builds, only renames symbols (it does not protect secrets), and code that depends on names breaks (for example `runtimeType.toString()` comparisons); enum names are not obfuscated. The page does not cover Crashlytics, R8 or iOS dSYM files; use the crash provider's docs for those. If the project's release lanes do not keep the symbols directory, say so in the report: it is a gap for the next crash.

## 4. Fix and verify

- Make the smallest change that removes the cause. If two causes are involved, fix them separately.
- Check with the reproduction steps on the same platform and build mode where it failed. Say which platforms you could not check (an iOS bug cannot be confirmed from a Linux session).
- Look for the same pattern elsewhere (`grep` for the same call or widget shape) and list the places; fix them only if the developer agrees.

## 5. When you are stuck

Say what you tried, what you ruled out, and the one thing that would unblock you (a full log, `flutter doctor -v` output, a minimal reproduction, a device). Do not widen the change to hide the symptom (a try-catch that swallows the error, a delay, a forced rebuild).
