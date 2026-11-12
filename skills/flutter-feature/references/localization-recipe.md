# Localization (multiple languages, plurals, right-to-left, store listing)

As of 2026-11-11: commands and rules below were read on the linked official pages on that date. Re-check them before relying on them. *Unverified* marks what the pages read did not say. Written for any state-management stack; the project's own setup and string rules win over this file.

## First: what the project already does

Look for `l10n.yaml`, `flutter: generate: true` in `pubspec.yaml`, `lib/l10n/*.arb`, `flutter_localizations` and `intl` in dependencies, a locale setting in the app's settings state, and `CFBundleLocalizations` in `ios/Runner/Info.plist`. Extend what exists. Do not add a second system (for example `easy_localization` beside gen-l10n) without asking.

## Set up gen-l10n (Flutter's built-in tool)

1. `flutter pub add flutter_localizations:"{sdk: flutter}" intl:any`, and `generate: true` under the `flutter:` section of `pubspec.yaml`.
2. `l10n.yaml` in the project root. The documented defaults are `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-localization-file: app_localizations.dart`; write them out so the setup is visible. Other options the page lists: `output-class`, `nullable-getter` (default true; `false` removes the `!` at call sites), `synthetic-package`, `use-escaping`, `preferred-supported-locales`, `untranslated-messages-file`, `use-named-parameters`.
3. One ARB file per language (`app_en.arb` is the template; the others hold translations only). Generation runs on `flutter pub get` and `flutter run`; `flutter gen-l10n` runs it by hand.
4. Wire the app: `localizationsDelegates: [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates]` (Cupertino: `GlobalCupertinoLocalizations.delegates`) and `supportedLocales: AppLocalizations.supportedLocales`. Use `AppLocalizations.of(context)` in widgets; it only works below the `MaterialApp`, so a string needed above it (the app title) uses `onGenerateTitle`.
5. Locale resolution when the device language is not supported: the first supported locale with the same language code, else the first entry of `supportedLocales`. Put the default language first.

## ARB syntax that matters

- **Placeholder:** `"hello": "Hello {userName}"` plus an `@hello` entry with `placeholders` and `type`. Add a `description` for every message; translators see it.
- **Plural:** `"{count, plural, =0{no items} =1{1 item} other{{count} items}}"`. Only the `other` case is required; languages with more forms (few, many) need those cases in their own ARB. Never build a plural with `count == 1 ? '' : 's'` in code (a common mistake, for example a message like `{count} new item{suffix}`), because other languages need different forms.
- **Select:** `"{gender, select, male{he} female{she} other{they}}"`. Matching is case-sensitive.
- **Numbers, currency, dates:** use `format` on the placeholder (`compact`, `currency`, `decimalPattern`, `percentPattern`; for `DateTime`, patterns such as `yMd`) so the `intl` locale rules apply. Do not format with string concatenation or fixed patterns like `dd/MM/yyyy`.
- **Quotes and braces:** a literal `{` needs `use-escaping: true` and single-quote escaping.

## Rules for the code

- Every user-visible string comes from the ARB files, including semantics labels and tooltips, validation messages, notification text and error messages. A cubit, bloc or repository that must produce text returns an error type or key, and the widget maps it to a localized string; this avoids needing a `BuildContext` below the UI.
- Never concatenate translated pieces into a sentence; use one message with placeholders (word order differs between languages).
- Do not hard-code text length: German and Finnish run long, CJK is short. Allow wrapping, test at the largest text scale, and avoid fixed-width buttons.
- Keep the user's chosen language in settings storage and pass it to `MaterialApp.locale`; `null` means follow the device.
- Server-provided text (API errors, content) is not covered by ARB. Decide with the backend owner: return codes the app localizes, or accept a `Accept-Language` header and localize on the server. Ask which.

## Right-to-left (Arabic, Hebrew, Persian, Urdu)

- The widgets delegate sets the text direction from the locale; `Directionality` flips `Row`, `ListView` and padding automatically only if the code uses direction-aware values.
- Use `EdgeInsetsDirectional` (start and end instead of left and right) and the `Directional` alignment and border-radius variants *(Unverified: the EdgeInsetsDirectional page read did not name them; check `AlignmentDirectional` and `BorderRadiusDirectional` in the API docs)*. Search for `EdgeInsets.only(left:`, `Alignment.centerLeft`, `Positioned(left:` and `TextAlign.left`.
- Icons that show direction (back arrows, progress, send) must mirror; icons that show a real thing (a clock, a phone) must not.
- Test by switching the app locale to an RTL language on a debug build. Visual checks need a running app, so say what was not looked at.

## Android and iOS native side

- **iOS:** the Flutter docs say to add the supported languages in Xcode: open `ios/Runner.xcodeproj`, select the `Runner` project, the Info tab, Localizations, `+`. This keeps the App Store entry and the Settings language list correct. The project file records the list in `CFBundleLocalizations` in `Info.plist` *(the Wonderous project does this; the Flutter page does not name the key)*.
- **Android per-app language (Android 13 or later):** a language list for the system's per-app language setting is declared with `generateLocaleConfig = true` under `android { androidResources { } }` in the app's Gradle file (needs AGP 8.1 or later and compileSdk 33 or later) plus `res/resources.properties` with `unqualifiedResLocale=en-US`. Or write `res/xml/locale_config.xml` and set `android:localeConfig` in the manifest; doing both fails the build. Without it, users cannot set the app's language separately from the system's. [Android docs](https://developer.android.com/guide/topics/resources/app-languages) (updated 2026-10-23). *Unverified: how this interacts with Flutter's own locale handling when the user picks a language in the in-app switcher; test on a real device.*
- **Localized app name (the name under the icon):** Android: `android:label="@string/app_name"` with `res/values-<lang>/strings.xml` for each language; the default `res/values/strings.xml` must contain every string or the app can fail on an unsupported locale (Android localization guide, updated 2026-11-10). iOS: `InfoPlist.strings` per language with `CFBundleDisplayName` and `CFBundleName` (Use Your Loaf, 2010, old; check Apple's docs *(Unverified for current Xcode)*).
- Permission texts in `Info.plist` (camera, location, and so on) are shown in the system's language and need their own `InfoPlist.strings` per language, or they stay in English *(Unverified on this read; test with a device set to a non-English language)*.

## Store listings per language

- **Google Play:** Store listing, Manage translations. Name 30 characters, short description 80, full description 4,000 (Play Console help). Text can be your own or machine-translated; if you add text without localized graphics, the default language's screenshots show. Localized screenshots are added per language.
- **App Store:** the primary language is the fallback for any language you do not provide. Name 2 to 30 characters and subtitle up to 30 (localizable); description up to 4,000; keywords up to 100 **bytes** (counted in bytes, so non-Latin scripts fit far fewer); promotional text 170 characters; screenshots are per localization. [Apple help](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information/) (read 2026-11-11, the page was truncated before What's New).
- Capture and frame screenshots per language with `flutter-store-assets` (the headline text must be in that language). Fastlane folders per locale are in its `screenshots.md`.
- Review and privacy pages: the privacy policy and support URLs should exist in each language you list *(judgment; not a stated rule)*.

## Workflow for adding a language

1. Confirm the language list, the default language, who translates (people, a service, or machine translation with a human check), and whether RTL is in scope. Ask if not given.
2. Add `app_<lang>.arb` containing the same keys; run `flutter gen-l10n`; read the untranslated-messages report if `untranslated-messages-file` is set.
3. Add the language to `supportedLocales` (already automatic when `AppLocalizations.supportedLocales` is used), the locale switcher, iOS Localizations and the Android locale config.
4. Check plurals, dates and numbers in that language; check layout at the largest text scale; check RTL if applicable.
5. Update store listings and screenshots for the language. Report what was not seen on a device.

## What to tell the requester

Translation is the long part and needs a human reader per language; machine translation of UI text can pick the wrong word for short labels. Effort per added language is small once the app is fully extracted into ARB; extracting an app with text scattered in widgets is the large cost (days, proportional to the number of screens). *(Judgment, not measured.)*
