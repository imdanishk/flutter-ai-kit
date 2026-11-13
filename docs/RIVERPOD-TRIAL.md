# Riverpod trial guide

Two runs that put the kit through a Riverpod project, with copy-paste commands and prompts. Written 2026-11-13 for kit 0.19.4, for Windows with PowerShell, FVM and an Android emulator. Android and Firebase only (no Apple account needed).

- **Run A** — an existing open-source Riverpod project (a throwaway clone): profile, review, plan, feature, testing, localization, app size, design, store assets, release dry run.
- **Run B** — a new Riverpod project made with the kit, wired to Firebase (Auth, Analytics, Crashlytics, App Distribution), built, uploaded and crash-tested.

What a Riverpod project changes: `flutter-feature`, `flutter-testing`, `flutter-review` and `flutter-new-project` have Riverpod-specific paths. `flutter-plan`, `flutter-design`, `flutter-store-assets`, `flutter-release` and `flutter-service-setup` do not depend on state management, so they are checked on the same projects but a pass there says little about Riverpod. The main thing to catch is any step where the agent drifts to Cubit, Freezed or injectable in a project that does not use them.

## How to run (applies to both runs)

- One stage at a time. Start a fresh agent session per stage if usage is tight; every prompt reads `KIT-TRIAL/RULES.md` first, so no context is lost.
- Each stage writes one short report file in `KIT-TRIAL/`. At the end one prompt merges them into `TRIAL-REPORT.md`. Attach that single file.
- **Low-usage order.** Run A: A0, A1, A3, A4, A5 first; the rest when you have room. Run B: B0 to B5, B8 first; B6 (Firestore) and B9 last.
- Any model works. The report records which one ran.
- If a stage fails, do not fix it by hand. Let the agent write down what happened and move on.

## Once on this computer

```powershell
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
firebase --version
flutterfire --version
```

If `flutterfire` is not found, add `%LOCALAPPDATA%\Pub\Cache\bin` to PATH and open a new terminal. Use a Google account you can throw away or one you do not mind linking to a free Firebase project.

## The rules file (used by every stage)

Run this inside each project folder after you create `KIT-TRIAL` (the commands below do both):

```powershell
New-Item -ItemType Directory -Force KIT-TRIAL | Out-Null
Add-Content .git\info\exclude "KIT-TRIAL/"
@'
# Trial rules
- Work only in this folder on branch kit-trial. Never push, never add a remote.
- Use FVM: `fvm flutter`, `fvm dart`. Run analyze as `fvm flutter analyze --no-pub`.
- Use the kit skill the prompt names. If it is not installed, say so and stop. Do not redo it from memory.
- Follow the project's own conventions over the kit's defaults. If the kit's instructions would make you use a different state management, router, or folder layout than the project has, follow the project and write the conflict down.
- Format only files you created or changed. Never create, restore, print or copy env files, keys, tokens, keystores or service account files, and never recover them from git history.
- If a step fails: stop, copy the exact command and the exact message, write it in the report. Do not work around it silently. At most two attempts per failure.
- Do not edit the kit's files. Do not "improve" the kit. Report problems; I will fix the kit.
- Be honest. A report that says "worked" must name the command and result that shows it. Do not flatter the kit, and do not hide failures or things you skipped.
- In reports replace emails with <email> and tokens or keys with <redacted>. Do not include company or personal names.
- Keep output short: do not print whole files, show only the lines that matter.
- Stage report format (write to KIT-TRIAL/<stage>.md):
  1. Commands run, with exit code or result.
  2. What the skill told me to do, and whether I followed it.
  3. What worked.
  4. What failed, was unclear, or was wrong (exact messages; name the kit file and section if you can).
  5. Places the kit pushed toward Cubit, Freezed, injectable or another stack the project does not use.
  6. Anything I skipped, and why.
'@ | Set-Content KIT-TRIAL\RULES.md
```

---

# Run A — existing Riverpod project

The project: `ssoad/flutter_riverpod_clean_architecture` (open source). Riverpod 3 with generator, go_router, Freezed, ARB localization in six languages, tests, Fastlane, a `tasks` and a `posts` feature. It has no Firebase config of its own, so Run A does not touch Firebase; Run B does.

## A0. Clone and baseline (you, about 5 minutes)

```powershell
cd C:\Users\Lenovo\FlutterProjects
git clone https://github.com/ssoad/flutter_riverpod_clean_architecture.git trial-riverpod-existing
cd trial-riverpod-existing
git remote remove origin
git checkout -b kit-trial
fvm use stable
New-Item -ItemType Directory -Force KIT-TRIAL | Out-Null
Add-Content .git\info\exclude "KIT-TRIAL/"
fvm flutter pub get
fvm flutter analyze --no-pub *> KIT-TRIAL\baseline-analyze.txt
fvm flutter test *> KIT-TRIAL\baseline-test.txt
npx skills add imdanishk/flutter-ai-kit --yes
```

Then create the rules file (section above). The baseline files record what was already broken before the kit touched anything, so failures are not blamed on the kit. If `pub get` fails, copy the message into `KIT-TRIAL\baseline-pubget.txt` and tell me.

Open the folder in your agent (OpenCode, VS Code, anything).

## A1. Profile

```text
Read KIT-TRIAL/RULES.md and follow it. Use the flutter-project-profile skill on this project.
Then write KIT-TRIAL/A1-profile.md. In section 3 answer: does AGENTS.md name the state management (and whether providers are generated or hand-written), router, localization, test setup, and Fastlane? What did the project do that the profile missed or got wrong? How many lines is the managed block?
```

## A2. Review

```text
Read KIT-TRIAL/RULES.md and follow it. Use the flutter-review skill on the tasks feature (lib/features/tasks and test/features/tasks). Do not change code.
Write KIT-TRIAL/A2-review.md with findings as file:line, each tagged: project-rule conflict, Riverpod-specific (ref.watch vs ref.read, ref.mounted after await, provider lifetime and autoDispose, family keys), or general. Say which findings you checked by reading the code and which you did not.
```

## A3. Plan

```text
Read KIT-TRIAL/RULES.md and follow it. Use the flutter-plan skill. Request: add Favorites to posts. A user can favorite or unfavorite a post from the list and the detail screen, a Favorites screen lists them, favorites survive an app restart, already-loaded posts work offline. No code.
Save the plan as KIT-TRIAL/A3-plan.md (flows, slices, assumptions, blockers kept separate). In the report, say whether the slices match how this project is actually organised (features/posts/{data,domain,presentation,providers}).
```

## A4. Feature (slice 1)

```text
Read KIT-TRIAL/RULES.md and follow it. Use the flutter-feature skill to build slice 1 only of KIT-TRIAL/A3-plan.md, using the existing posts feature as the exemplar.
Match the project: its providers, its error handling, its folder layout, its router. Run `fvm dart run build_runner build` only if you added generated code. Verify with `fvm flutter analyze --no-pub` and compare with KIT-TRIAL/baseline-analyze.txt: new issues only.
Write KIT-TRIAL/A4-feature.md. Include: files created or changed, whether you used the generator or hand-written providers and why, and the Rule conflicts line from the skill's summary.
```

## A5. Testing

```text
Read KIT-TRIAL/RULES.md and follow it. Use the flutter-testing skill for the code from stage A4: one provider or notifier test using a ProviderContainer with an overridden repository, and one widget test. Reuse the project's own test setup (test/flutter_test_config.dart, mocktail, existing helpers). Run the new tests, then the full suite, and compare with KIT-TRIAL/baseline-test.txt.
Write KIT-TRIAL/A5-testing.md.
```

## A6. Localization

```text
Read KIT-TRIAL/RULES.md and follow it. Use the localization recipe of the flutter-feature skill. Put every user-visible string of the Favorites screen into the project's ARB files for English plus one other language it already has. Regenerate with the project's own method. List the locales that still lack the new keys; do not translate the rest.
Write KIT-TRIAL/A6-l10n.md. Say whether the recipe matched how this project does localization.
```

## A7. App size (no code changes)

```text
Read KIT-TRIAL/RULES.md and follow it. Use the flutter-fix skill and its performance-and-app-size reference. Do not change code.
Run `fvm flutter build apk --release --analyze-size`. Report the top five size contributors and which dependency each comes from, whether heavy packages in pubspec (for example grpc, protobuf, workmanager, flutter_tts) are actually used in lib/, and at most three changes ranked by saving and risk. Mark every claim you did not measure as unmeasured.
Write KIT-TRIAL/A7-size.md.
```

## A8. Design

```text
Read KIT-TRIAL/RULES.md and follow it. Use the flutter-design skill on the Favorites screen from stage A4. First read the project's theme and tokens. Propose two layouts in plain text (no code), pick the one you would ship and say why, then implement it with the project's existing theme and no new packages.
Write KIT-TRIAL/A8-design.md. Then run: fvm flutter run -d emulator-5554 --no-resident  (tell me if the app fails to start; a missing Firebase setup is the project's own state, write it down and do not add Firebase).
```

You: look at the emulator, and tell me in one line whether the screen looks right.

## A9. Store assets

```text
Read KIT-TRIAL/RULES.md and follow it. Use the flutter-store-assets skill. Prepare Google Play listing assets for this app in a store/ folder: an icon source, a feature graphic, and a screenshot list with the sizes Google Play requires today (check the current Play page and name it). Keep the project's own icon tool (flutter_launcher_icons is in pubspec). Upload nothing.
Write KIT-TRIAL/A9-store.md with which sizes you verified from the page and which you did not.
```

## A10. Release dry run

```text
Read KIT-TRIAL/RULES.md and follow it. Use the flutter-release skill. Read the project's existing Fastlane and CI setup and compare it with the kit's references. Then build an Android release with obfuscation: `fvm flutter build apk --release --obfuscate --split-debug-info=build/symbols`. Upload nothing and do not run Fastlane lanes that upload.
Write KIT-TRIAL/A10-release.md: what the project already had, what the kit would add, any wrong or missing instruction.
```

## A11. Merge report

```text
Read KIT-TRIAL/RULES.md. Merge every KIT-TRIAL/A*.md into KIT-TRIAL/TRIAL-REPORT-A.md using exactly this layout:
1. Setup: OS, Flutter and Dart versions, agent and model, kit version (from the AGENTS.md block marker).
2. Table: stage, skill, result (ok / partly / failed / skipped), one line.
3. Issues: numbered; each with stage, kit file and section if known, exact message or behavior, what you expected, severity (blocks work / wastes time / minor).
4. Places the kit pushed toward Cubit, Freezed or injectable.
5. What the kit did well, with the evidence.
6. Redaction check: confirm no emails, tokens, keys, or personal names are in the file.
Do not add anything the stage reports do not support.
```

Attach `KIT-TRIAL\TRIAL-REPORT-A.md`.

---

# Run B — new Riverpod project with Firebase

The app: **Kit Notes**. Email and password sign-in, a notes list with add, edit and delete, analytics events, crash reporting. Package name `com.example.kittrial`. Firebase's free Spark plan covers everything here (the console tells you if something needs billing).

## B0. Folder (you, 2 minutes)

```powershell
cd C:\Users\Lenovo\FlutterProjects
mkdir trial-riverpod-new
cd trial-riverpod-new
git init
git checkout -b kit-trial
New-Item -ItemType Directory -Force KIT-TRIAL | Out-Null
Add-Content .git\info\exclude "KIT-TRIAL/"
npx skills add imdanishk/flutter-ai-kit --yes
```

Create the rules file (see above). Open the folder in your agent.

## B1. Create the project

```text
Read KIT-TRIAL/RULES.md and follow it. Use the flutter-new-project skill in this empty folder. Choices: app name kit_notes, org com.example (so the Android package is com.example.kittrial; set it if the tool names it differently and tell me the final package name), Android only, FVM pinned to the current stable, Riverpod 3 with generated providers, go_router, one language (English), no flavors, no tests. Do not add Firebase yet.
Verify: build_runner, `fvm flutter analyze --no-pub`, then `fvm flutter run -d emulator-5554 --no-resident`. Write KIT-TRIAL/B1-new-project.md.
```

## B2. Firebase console (you, 10 minutes, once)

1. Open console.firebase.google.com, **Add project**, name it `kit-trial-riverpod`, leave Google Analytics **on**, pick the default account, create.
2. **Build → Authentication → Get started → Sign-in method → Email/Password → Enable → Save.**
3. **App Distribution → Get started → Testers & Groups → Add group**, name `testers`, add your own email.
4. **Crashlytics** (under Release & Monitor) — open it once. It waits for the first crash; if it offers an Enable button, press it. (Exact wording not verified.)
5. Back in the terminal, in the project folder:

```powershell
firebase login
flutterfire configure
```

Choose your `kit-trial-riverpod` project, platforms: **Android only** (space to deselect the others). It creates the Android app in the console, writes `lib/firebase_options.dart` and `android/app/google-services.json`. Neither goes to git.

If `flutterfire configure` fails or asks for something unexpected, copy the exact text to `KIT-TRIAL\B2-configure.txt`; that is a result, not a mistake.

## B3. Wire the services

```text
Read KIT-TRIAL/RULES.md and follow it. firebase_options.dart and google-services.json now exist (do not print them). Use the flutter-service-setup skill to add firebase_core, firebase_auth, firebase_analytics and firebase_crashlytics to this app: add packages with `flutter pub add`, initialize Firebase in main() before runApp inside the Riverpod setup, wire both Crashlytics error paths (FlutterError.onError and PlatformDispatcher.instance.onError), add a Riverpod provider for FirebaseAuth and one for FirebaseAnalytics. Check the Firebase pages for the current Gradle plugin steps for Crashlytics instead of trusting memory; if flutterfire configure already added them, say so.
Add a crash-test button on a throwaway screen that calls FirebaseCrashlytics.instance.crash(). Show it only when kDebugMode is true or the build was made with --dart-define=CRASH_TEST=true (read with const bool.fromEnvironment), so a normal release build never has it.
Verify with analyze and an emulator run. List everything I still need to do in the Firebase console or share with a backend (per service). Write KIT-TRIAL/B3-services.md.
```

## B4. Plan

```text
Read KIT-TRIAL/RULES.md and follow it. Use the flutter-plan skill. Request: Kit Notes. Sign up and sign in with email and password (Firebase Auth), sign out, a notes list where each note has a title and body, add, edit and delete, notes saved per signed-in user, analytics events for sign-in, note created and note deleted, crashes reported. Slice 1 should be the auth flow; slice 2 notes in memory then local storage; Firestore last and marked optional. No code.
Save as KIT-TRIAL/B4-plan.md. Say whether the plan kept assumptions, blockers and the session's own limits apart.
```

## B5. Feature slices 1 and 2

Run once per slice, replacing `N`:

```text
Read KIT-TRIAL/RULES.md and follow it. Use the flutter-feature skill to build slice N of KIT-TRIAL/B4-plan.md only, in the project's Riverpod style (generated providers, AsyncValue, ref.mounted after awaits, go_router routes with a redirect for signed-out users). Verify with `fvm flutter analyze --no-pub` and an emulator run. For auth, check at least: sign-up, sign-in, wrong password message, sign-out; tell me which of these you tested on the emulator and which you could not.
Write KIT-TRIAL/B5-slice-N.md including the skill's Rule conflicts line.
```

You: on the emulator, sign up with a fake email and a password, then sign out and in. Then in the console, **Authentication → Users** should list it. Tell me yes or no.

## B6. Firestore (optional, last)

Console: **Build → Firestore Database → Create database**, production mode, closest region. Then:

```text
Read KIT-TRIAL/RULES.md and follow it. Use flutter-feature for the Firestore slice of KIT-TRIAL/B4-plan.md: notes stored under users/{uid}/notes. Write the security rules file so a user can only read and write their own notes, and tell me the exact command to deploy it (do not run firebase deploy yourself). Write KIT-TRIAL/B6-firestore.md.
```

You: run the deploy command it gives, in the project folder.

## B7. Testing

```text
Read KIT-TRIAL/RULES.md and follow it. Use the flutter-testing skill: one notifier test for the auth provider and one for the notes provider, each with an overridden repository (no real Firebase), and one widget test for the notes list. Run them and write KIT-TRIAL/B7-testing.md.
```

## B8. Release, symbols, crash test, App Distribution

```text
Read KIT-TRIAL/RULES.md and follow it. Use the flutter-release skill and its crash-and-symbols reference, and the Firebase CLI route in fastlane-and-ci.md section 3a. This project has no Fastlane, so do not add it.
1. Find the Firebase App ID in the project (it is not secret) and tell me which file it came from.
2. Build: `fvm flutter build apk --release --obfuscate --split-debug-info=build/symbols --dart-define=CRASH_TEST=true`
3. Upload symbols: `firebase crashlytics:symbols:upload --app=<APP_ID> build/symbols`
4. Upload the APK: `firebase appdistribution:distribute <the apk path> --app <APP_ID> --groups testers --release-notes "trial build"` (list build/app/outputs/flutter-apk/ for the real file name)
5. Install the same APK on the emulator: `adb install -r <the apk path>` (or `fvm flutter install`).
Tell me which of these you ran, with results, then stop and wait for me. Write KIT-TRIAL/B8-release.md.
```

You, after it finishes:

1. Open the app on the emulator, press the crash button, then **reopen the app once** (Crashlytics sends the report on the next launch).
2. Wait a few minutes, open **Crashlytics** in the console. Does a crash appear? Is the stack trace readable (names of your own functions) or obfuscated (letters like `a.b.c`)?
3. **App Distribution → Releases**: is the build listed, and is it assigned to `testers`?
4. Optional (needs a real Android phone): open the invite email on the phone, install through the link, and run it.
5. **Analytics → DebugView** (optional): `adb shell setprop debug.firebase.analytics.app com.example.kittrial`, open the app, sign in. Events show within a minute in DebugView and up to a day in normal reports.

Tell me the answers in two or three lines; the agent does not need them.

## B9. Design and store assets

```text
Read KIT-TRIAL/RULES.md and follow it. Use flutter-design to give Kit Notes a consistent theme (colors, typography, spacing) and restyle the sign-in screen and the notes list, no new packages. Then use flutter-store-assets to prepare a Google Play icon source, feature graphic and screenshot list in store/ at the sizes Play requires today, naming the page you checked. Write KIT-TRIAL/B9-design-store.md.
```

## B10. Merge report

Same prompt as A11, with `A*.md` replaced by `B*.md` and the output file `KIT-TRIAL/TRIAL-REPORT-B.md`. Add to the layout: a section 7, "Firebase: what each service needed that the kit did not say".

Attach `KIT-TRIAL\TRIAL-REPORT-B.md`.

---

# Afterwards

## Clean up (when both reports are sent)

```powershell
cd C:\Users\Lenovo\FlutterProjects
Remove-Item -Recurse -Force trial-riverpod-existing, trial-riverpod-new
firebase logout
```

In the Firebase console: **Project settings → General → Delete project** for `kit-trial-riverpod` if you do not want to keep it.

## What the reports are checked for

- Every claim in a report is checked against the kit's files before anything changes.
- Findings that belong to the project and not the kit (its own analyzer issues, its own failing tests, its own missing Firebase config) are separated from kit faults.
- Fixes ship as one kit version; the reports and the fixes are listed in the changelog.
- Not proven by these runs: iOS, App Store and TestFlight, Google Play upload, and the 16 KB page-size claim. They stay on the roadmap (`docs/ROADMAP.md`).
