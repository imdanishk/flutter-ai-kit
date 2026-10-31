# B. Authentication, security and compliance

Shared assumptions: one mid/senior Flutter developer, design and backend APIs ready, QA and store review excluded. Package versions were read from pub.dev on 2026-10-30; policy text was read from Apple and Google pages where noted. The research budget ran out part way through, so entries marked "Partly verified" or "Unverified (Verify)" rest on well-known platform behaviour that must be re-checked in the next refresh. Biggest decisions: pick one identity provider first (Firebase Authentication, Auth0, Cognito or Supabase decide most of sign-in, MFA and passkeys); never treat client-side protection (root detection, pinning, obfuscation) as real security; and treat compliance items (account deletion, privacy manifest, consent, kids) as release blockers, not polish. Correction to the inventory: Apple guideline 4.8 no longer names Sign in with Apple; it requires an "equivalent" login service with privacy features.

## Sign-in and identity

### Email/password and phone OTP
<!-- meta: size=M; days=3-8; deps=backend, third-party-sdk, paid-service, native-android, native-ios; platform-difference=significant -->
- **Brief:** Core account creation and login by email and password or a one-time SMS code. Almost every app with accounts needs it.
- **Seen in:** WhatsApp (phone OTP), Uber, Airbnb, Spotify.
- **Recommended approach:** If there is no existing backend, `firebase_auth` 7.0.1 (publisher firebase.google.com, not discontinued). If the team has a NestJS or similar backend, own the sessions there and use a managed provider only for SMS. `auth0_flutter` 2.6.2, `amplify_auth_cognito` 2.15.0 and `supabase_flutter` 2.18.3 are valid when that vendor is already chosen. Rejected: hand-rolled OTP over a raw SMS gateway without rate limiting.
- **Effort:** M, 3-8 days. Range driven by provider choice, password reset and verification flows, and backend token exchange.
- **Depends on:** Backend or managed identity provider; paid SMS (Firebase limits SMS by billing plan); real device for phone sign-in.
- **Android/iOS differences:** significant. Firebase phone auth needs the SHA-1 fingerprint registered on Android; iOS needs push notifications, an APNs key in Firebase and the remote-notification background mode. Auto-retrieval of the SMS code and the resend token exist on Android only.
- **Custom work after the package:** Error and rate-limit UX, resend timers, phone number formatting, account linking, password reset, backend session handoff.
- **Pitfalls and store review:** Phone sign-in does not work on emulators. SMS fraud (toll fraud) and quota limits; Firebase stores numbers for abuse prevention, so consent text is needed.
- **What to tell the requester:** Fully achievable. Ask: SMS volume and countries (cost), whether a backend already owns users, and whether login must work without a phone number.
- **Status:** Verified 2026-10-30 from pub.dev/packages/firebase_auth, supabase_flutter, auth0_flutter, amplify_auth_cognito and firebase.google.com/docs/auth/flutter/phone-auth. Provider pricing: Verify.

### Social sign-in (Google, Apple, Facebook)
<!-- meta: size=M; days=3-8; deps=backend, third-party-sdk, native-android, native-ios, store-approval; platform-difference=significant -->
- **Brief:** One-tap login through an existing Google, Apple or Facebook account, reducing password friction.
- **Seen in:** Spotify, Pinterest, Duolingo, Airbnb.
- **Recommended approach:** `google_sign_in` 7.2.0 (flutter.dev, published Sep 17, 2025), `sign_in_with_apple` 8.2.0 (aboutyou.com, Aug 27, 2026), `flutter_facebook_auth` 7.2.0 (meedu.app, Jul 3, 2026). Send the provider ID token to your backend and verify it there. Facebook is optional; drop it unless the audience needs it.
- **Effort:** M, 3-8 days for all three. Driven by console setup per provider and backend token verification.
- **Depends on:** Backend verification; Google Cloud and Apple Developer (paid membership) and Meta developer accounts; store approval.
- **Android/iOS differences:** significant. Apple needs the Sign in with Apple capability (sign-in fails silently if missing). On Android Apple runs through a browser flow: a callback activity in the manifest, `singleTop` or `singleTask` launch mode and a server redirect. Google needs per-platform client IDs and the `serverClientId`.
- **Custom work after the package:** Backend ID-token verification, account linking when emails match, handling Apple's private relay email, logout and revoke.
- **Pitfalls and store review:** Apple 4.8 (verified): apps offering Google or Facebook login must offer an equivalent login service that limits data to name and email, can hide the email and does not track for ads. Sign in with Apple satisfies this. Google 7.x API changes: Verify migration guide.
- **What to tell the requester:** Achievable. Apple is effectively mandatory on iOS when Google or Facebook is offered. Ask which providers matter and who owns the developer accounts.
- **Status:** Verified 2026-10-30 from the three pub.dev pages and developer.apple.com/app-store/review/guidelines.

### OAuth2/OIDC with PKCE
<!-- meta: size=M; days=2-6; deps=backend, third-party-sdk, native-android, native-ios; platform-difference=significant -->
- **Brief:** Browser-based sign-in against an enterprise or custom identity provider (Keycloak, Okta, Azure AD, Auth0), keeping credentials out of the app.
- **Seen in:** Microsoft 365 apps, Slack, banking apps.
- **Recommended approach:** `flutter_appauth` 12.1.0 (dexterx.dev, Aug 29, 2026), a wrapper over the AppAuth native SDKs with PKCE. Use `auth0_flutter` instead when Auth0 is the provider. Rejected: embedded web views for login.
- **Effort:** M, 2-6 days. Driven by provider quirks and token storage.
- **Depends on:** An OIDC provider with a registered public client; native code is configuration only.
- **Android/iOS differences:** significant. Android: `appAuthRedirectScheme` manifest placeholder (lowercase) in the Gradle file, AndroidX. iOS: custom URL scheme under `CFBundleURLTypes`; `preferEphemeralSession` needs iOS 13 or later; iOS caches tokens in `cache.db` unless disabled.
- **Custom work after the package:** Store refresh tokens in secure storage, silent refresh, logout and end-session endpoint, discovery document handling.
- **Pitfalls and store review:** Custom URL schemes can be hijacked on older Android; prefer verified HTTPS redirects where the provider supports them (Verify).
- **What to tell the requester:** Standard and reliable. Ask for the provider, redirect URI rules and whether single sign-on across apps is needed.
- **Status:** Verified 2026-10-30 from pub.dev/packages/flutter_appauth and auth0_flutter.

### Passkeys
<!-- meta: size=M; days=5-12; deps=backend, third-party-sdk, native-android, native-ios; platform-difference=significant -->
- **Brief:** Passwordless sign-in using device-bound FIDO credentials (Face ID, fingerprint, screen lock), synced through iCloud Keychain or Google Password Manager.
- **Seen in:** Google, PayPal, Amazon, WhatsApp.
- **Recommended approach:** `passkeys` 2.23.1 (corbado.com, Sep 14, 2026, BSD-3-Clause, not discontinued), which needs Dart 3.9 and Flutter 3.35 or later and supports Android, iOS, macOS, web and Windows. Alternatives: `auth0_flutter` (supports passkeys on Android, iOS and web) or Supabase built-in passkeys (Supabase marks them beta: Verify). The package contains no server; you need a WebAuthn relying-party server.
- **Effort:** M, 5-12 days, mostly backend WebAuthn and recovery flows; the client part is small.
- **Depends on:** Backend WebAuthn server (custom or managed); hosted domain files.
- **Android/iOS differences:** significant. Android: `assetlinks.json` served without redirects as `application/json`; the relying-party ID must match the hosting domain (relation name and which signing fingerprints to list: Verify). iOS: enable biometrics; simulators need enrolled Face ID; the package page documents the apple-app-site-association file and Associated Domains entitlement for macOS (the exact iOS `webcredentials:` entry: Verify). Same hosting pattern as App Links in 01-data-sharing-and-linking.md.
- **Custom work after the package:** Registration and sign-in ceremonies, fallback login, credential management screen, account recovery.
- **Pitfalls and store review:** The package page gives no general minimum OS. Restore credentials need Android 9 (API 28) or later with Google Play services; the PRF extension needs iOS 18 or later. The Auth0 SDK states Android 9 or later and iOS 16.6 or later for its mobile passkey methods.
- **What to tell the requester:** Feasible, but a server is mandatory and a fallback login must remain. Ask whether passkeys replace or supplement passwords.
- **Status:** Partly verified 2026-10-30 from pub.dev/packages/passkeys and pub.dev/packages/auth0_flutter. Verify: Supabase beta label, Android assetlinks relation and fingerprints, iOS entitlement entry (Apple and Android passkey pages did not return their text).

## Sessions and local protection

### Biometric auth
<!-- meta: size=S; days=1-2; deps=flutter-only, native-android, native-ios; platform-difference=minor -->
- **Brief:** Fingerprint or face check to unlock the app or confirm a sensitive action.
- **Seen in:** Banking apps, WhatsApp chat lock, 1Password.
- **Recommended approach:** `local_auth` 3.0.2 (flutter.dev, Jul 9, 2026; Android SDK 24 or later, iOS 13 or later, macOS and Windows). No credible alternative needed.
- **Effort:** S, 1-2 days, driven by fallback and error states.
- **Depends on:** Flutter-only plus platform setup.
- **Android/iOS differences:** Minor. `biometricOnly: true` forces biometrics (not supported on Windows); by default PIN, pattern or passcode is allowed as fallback. Android: use `FlutterFragmentActivity` (a `FragmentActivity` is required), add the `USE_BIOMETRIC` permission, and make the `LaunchTheme` parent a `Theme.AppCompat` theme to prevent crashes on Android 8 and below. iOS: add `NSFaceIDUsageDescription` to `Info.plist`.
- **Custom work after the package:** Lockout handling (the package throws `LocalAuthException` with codes such as `temporaryLockout` and `biometricLockout`), enrolment checks, what happens when biometrics change.
- **Pitfalls and store review:** The result is a boolean on the client, not proof for a server; binding real secrets to a keystore key is not covered by the package pages (Verify).
- **What to tell the requester:** Easy. It is a convenience gate, not server-grade authentication.
- **Status:** Verified 2026-10-30 from pub.dev/packages/local_auth, local_auth_android and local_auth_darwin. Keystore binding advice: Verify.

### Token refresh and sessions
<!-- meta: size=M; days=2-5; deps=flutter-only, backend; platform-difference=none -->
- **Brief:** Attach access tokens, refresh on 401 once, queue parallel requests, and sign out cleanly when refresh fails.
- **Seen in:** Any app with accounts (Instagram, Uber, Netflix).
- **Recommended approach:** A `dio` 5.11.1 (flutter.cn, Sep 4, 2026, not discontinued) interceptor; its docs describe `QueuedInterceptor`, which runs requests through the interceptor one at a time, a fit for a single in-flight refresh. Tokens go in `flutter_secure_storage` 11.2.0 (Sep 16, 2026; Android AES-GCM with RSA-OAEP key wrapping, min SDK 23; iOS Keychain, default accessibility `unlocked`). Ferry or GraphQL users do the same in a link.
- **Effort:** M, 2-5 days. Driven by race conditions and multi-device logout.
- **Depends on:** Backend refresh endpoint with rotation.
- **Android/iOS differences:** None in Dart. Android backups can break stored keys (`Failed to unwrap key`); the package advises `android:allowBackup="false"`. Keychain data surviving uninstall on iOS: the package page does not say (Verify).
- **Custom work after the package:** Everything: queueing, retry policy, forced-logout events, token expiry on app resume.
- **Pitfalls and store review:** Concurrent refreshes invalidating rotated tokens is the classic bug.
- **What to tell the requester:** Achievable; quality depends on backend token design.
- **Status:** Partly verified 2026-10-30 from pub.dev/packages/dio and flutter_secure_storage. Verify: iOS Keychain survival after uninstall; the refresh pattern itself is design advice, not documented by either page.

### MFA
<!-- meta: size=M; days=3-8; deps=backend, third-party-sdk, paid-service; platform-difference=minor -->
- **Brief:** Second factor (SMS or authenticator code) at sign-in or for sensitive actions.
- **Seen in:** Google, GitHub, banking apps.
- **Recommended approach:** Use the identity provider's MFA: `firebase_auth` multi-factor, or `auth0_flutter` (its page describes an `mfa_token` flow during login and a My Account API for managing MFA methods). Prefer TOTP over SMS in principle, but the Firebase Flutter guide documents SMS only; its TOTP guides cover iOS, Android and web. Rejected: custom MFA.
- **Effort:** M, 3-8 days for enrolment, challenge and recovery codes.
- **Depends on:** Firebase needs the upgrade to Authentication with Identity Platform; SMS cost (pricing: Verify).
- **Android/iOS differences:** Minor; SMS auto-fill differs, as in phone OTP. Windows has no Firebase MFA.
- **Custom work after the package:** Enrolment UI, challenge screen (catch `FirebaseAuthMultiFactorException`), backup codes, lost-device support.
- **Pitfalls and store review:** Firebase requires a verified email before enrolment. Phone, anonymous and Apple Game Center sign-in cannot carry MFA, and multi-tenant use is unsupported on Flutter. Account recovery is the hard part.
- **What to tell the requester:** Achievable; ask which factors and risk level.
- **Status:** Verified 2026-10-30 from firebase.google.com/docs/auth/flutter/multi-factor, firebase.google.com/docs/auth/android/totp-mfa and pub.dev/packages/auth0_flutter. Verify: Flutter TOTP support, SMS pricing.

### Secure PIN / app lock
<!-- meta: size=M; days=3-6; deps=flutter-only; platform-difference=none -->
- **Brief:** In-app lock screen with PIN and optional biometrics after inactivity.
- **Seen in:** WhatsApp, banking and password manager apps.
- **Recommended approach:** `local_auth` 3.0.2 plus `flutter_secure_storage` 11.2.0; store a salted hash of the PIN, never the PIN. Custom lifecycle observer for lock timing.
- **Effort:** M, 3-6 days: lock-on-resume, retry limits, task switcher blur.
- **Depends on:** Flutter-only.
- **Android/iOS differences:** None in logic. Platform setup for biometrics is as in Biometric auth (Android `FragmentActivity` and `USE_BIOMETRIC`; iOS `NSFaceIDUsageDescription`). Hiding the task-switcher snapshot needs native handling on both (Verify).
- **Custom work after the package:** All of it: PIN screens, lockout, forgot-PIN flow, privacy overlay.
- **Pitfalls and store review:** Forgot-PIN must tie back to sign-in.
- **What to tell the requester:** Easy to build; local only, not a server defence.
- **Status:** Partly verified 2026-10-30 from pub.dev/packages/local_auth, local_auth_android, local_auth_darwin and flutter_secure_storage (versions, platform setup, storage). Verify: salted-hash PIN design and task-switcher blur have no source page.

## Client hardening

### Integrity attestation
<!-- meta: size=M; days=3-7; deps=backend, third-party-sdk, native-android, native-ios; platform-difference=significant -->
- **Brief:** Prove to the backend that requests come from the genuine app on a genuine device.
- **Seen in:** Google apps, banking and game apps.
- **Recommended approach:** `firebase_app_check` 0.5.1 (firebase.google.com, Oct 23, 2026; Android, iOS, macOS, web, Windows). Defaults: Play Integrity on Android, DeviceCheck on iOS and macOS; App Attest is opt-in (`AppleProvider.appAttest`, iOS 14 or later, macOS 14 or later); a debug provider exists for emulators and CI. Alternative for non-Firebase backends: call the Play Integrity and App Attest APIs through a custom channel.
- **Effort:** M, 3-7 days, driven by backend enforcement and debug-token handling.
- **Depends on:** Firebase or backend verification; Play Console and Apple capability.
- **Android/iOS differences:** significant. Register each app with its provider in the Firebase console and call `activate()` after `Firebase.initializeApp()`. Some Android devices need "Meets basic device integrity" enabled in Play Console. Signing SHA-256 registration and the App Attest Xcode capability: Verify, the page did not state them.
- **Custom work after the package:** Server-side token check, staged enforcement, debug providers for CI.
- **Pitfalls and store review:** Rooted or older devices may fail legitimately.
- **What to tell the requester:** Raises the bar; does not stop determined attackers.
- **Status:** Partly verified 2026-10-30 from pub.dev/packages/firebase_app_check and firebase.google.com/docs/app-check/flutter/default-providers. Correction: iOS default is DeviceCheck, not App Attest. Verify: SHA-256 and App Attest capability steps, Play Integrity quotas.

### Root, jailbreak and hook detection
<!-- meta: size=M; days=2-5; deps=third-party-sdk, paid-service, native-android, native-ios; platform-difference=minor -->
- **Brief:** Runtime checks for rooted or jailbroken devices, hooking tools and tampering.
- **Seen in:** Banking, payment and game apps.
- **Recommended approach:** `freerasp` 8.2.4 (talsec.app, published about 25 days before 2026-10-31; Android and iOS; not discontinued; MIT for the open-source part plus Talsec binary components). It detects root or jailbreak (Magisk, KernelSU, checkra1n), unlocked bootloader, hooks (Frida, LSPosed, Shadow), UI automation (Appium) and untrusted installs. The free tier has a fair usage policy. Other root checkers were not evaluated.
- **Effort:** M, 2-5 days.
- **Depends on:** Talsec's Flutter integration guide (not opened); the commercial tier adds AppiCrypt backend protection, extra features and support.
- **Android/iOS differences:** Minor (unverified); the package page gives no per-platform setup and points to Talsec's guide (Verify).
- **Custom work after the package:** Decide the response (warn, limit, block), report to backend.
- **Pitfalls and store review:** False positives block legitimate users; detection can be bypassed.
- **What to tell the requester:** A deterrent, not a guarantee.
- **Status:** Verified 2026-10-31 from pub.dev/packages/freerasp (version, platforms, detections, licence, tiers). Verify: per-platform setup (Talsec guide not opened), exact publish date.

### Certificate pinning
<!-- meta: size=M; days=1-3; deps=flutter-only, backend; platform-difference=minor -->
- **Brief:** Reject TLS connections whose certificate does not match known fingerprints.
- **Seen in:** Banking apps, Twitter, Signal.
- **Recommended approach:** `http_certificate_pinning` 3.0.2 (softarch.dev, published about 3 months before 2026-10-31; Apache-2.0; Android and iOS; not discontinued). It compares the server certificate's SHA-1 or SHA-256 fingerprint with fingerprints you supply, through a Dio interceptor, an `http` client or a direct check. Which certificate in the chain is compared, and whether a public-key pin is possible: Verify.
- **Effort:** S-M, 1-3 days, mostly rotation process.
- **Depends on:** Backend certificate operations; `dio` (>=4.0.6 <6.0.0) and `http` (^1.3.0) as package dependencies.
- **Android/iOS differences:** Minor (unverified); the page lists no platform setup. Android network security config as an alternative: Verify.
- **Custom work after the package:** Pin rotation plan, backup pins, remote kill switch.
- **Pitfalls and store review:** Expired pins brick the app until updated. The package's `http` example uses mismatched variable names (`allowedSHAFingerprints` and `certificateSHA256Fingerprints`), so do not copy it unchanged.
- **What to tell the requester:** Doable, but it creates an operational burden; ask who rotates certificates.
- **Status:** Partly verified 2026-10-31 from pub.dev/packages/http_certificate_pinning only. Verify: certificate compared, platform setup, Android network security config alternative, backup-pin and rotation advice (design advice, no source page).

### Obfuscation
<!-- meta: size=S; days=0-1; deps=flutter-only; platform-difference=minor -->
- **Brief:** Rename function and class names in compiled Dart code in release builds to slow reverse engineering. It does not encrypt resources.
- **Seen in:** Banking and game apps.
- **Recommended approach:** `flutter build <target> --obfuscate --split-debug-info=<dir>`, release builds only. Supported targets: `apk`, `appbundle`, `aar`, `ios`, `ipa`, `ios-framework`, Linux, macOS and Windows. Web is not supported (release web builds are minified instead). Add `--extra-gen-snapshot-options=--save-obfuscation-map=<file>` for a name map.
- **Effort:** S, under a day plus CI changes.
- **Depends on:** Flutter-only.
- **Android/iOS differences:** Minor. Same flags; each build writes a symbols file named per platform and architecture, and a crash must be matched to the right one.
- **Custom work after the package:** Back up the symbols file per release; decode crashes with `flutter symbolize -i <trace> -d <symbols>`; upload to the crash tool (Verify).
- **Pitfalls and store review:** Flutter's page calls storing secrets in an app a poor practice. Code that relies on names breaks (for example `runtimeType.toString()` checks); enum names are not obfuscated.
- **What to tell the requester:** Slows analysis only.
- **Status:** Verified 2026-10-31 from docs.flutter.dev/deployment/obfuscate. Verify: crash tool upload steps (no source page).

## Privacy and compliance

### Privacy manifest (iOS)
<!-- meta: size=S; days=1-2; deps=native-ios, store-approval; platform-difference=significant -->
- **Brief:** `PrivacyInfo.xcprivacy` describes the privacy practices of the app and its SDKs (keys include `NSPrivacyTracking`, `NSPrivacyTrackingDomains`, `NSPrivacyCollectedDataTypes` and `NSPrivacyAccessedAPITypes`).
- **Seen in:** Every App Store app.
- **Recommended approach:** Add the app manifest in Xcode (steps: Verify) and update plugins to versions that ship their own manifests. Xcode combines the manifests of all SDKs into one report, which helps fill the privacy labels. Apple's SDK list includes Flutter and many Flutter plugins (for example `path_provider`, `url_launcher`, `sqflite`).
- **Effort:** S, 1-2 days, driven by SDK count.
- **Depends on:** Native iOS configuration; store approval.
- **Android/iOS differences:** iOS only, significant.
- **Custom work after the package:** Audit each plugin, match the manifest to the App Store privacy answers.
- **Pitfalls and store review:** Apple requires the manifest and a signature for listed SDKs when a new app includes them or an update adds them; Xcode checks that a new SDK version has the same signer. The page gives no enforcement date or consequence (Verify in App Store Connect feedback).
- **What to tell the requester:** Mandatory housekeeping.
- **Status:** Partly verified 2026-10-31 from developer.apple.com/support/third-party-SDK-requirements. Verify: Apple's manifest and required-reason API documentation pages and docs.flutter.dev's privacy manifest page returned no article text; required-reason codes, enforcement, Flutter-specific steps.

### App Tracking Transparency
<!-- meta: size=S; days=1-1; deps=third-party-sdk, native-ios, store-approval; platform-difference=significant -->
- **Brief:** iOS prompt required before tracking users across other companies' apps.
- **Seen in:** Facebook, Instagram, any ad-supported app.
- **Recommended approach:** `app_tracking_transparency` 2.0.7 (he2apps.com, May 28, 2026); needs `NSUserTrackingUsageDescription`, iOS 14 or later.
- **Effort:** S, about 1 day.
- **Depends on:** Native iOS key.
- **Android/iOS differences:** iOS only; Android has no equivalent in this package.
- **Custom work after the package:** Pre-prompt screen, ad SDK configuration.
- **Pitfalls and store review:** Apple 5.1.2 (verified): tracking needs explicit ATT permission and the app cannot require it for access.
- **What to tell the requester:** Easy; skip it if no tracking happens.
- **Status:** Verified 2026-10-30 from pub.dev/packages/app_tracking_transparency and Apple guidelines.

### Consent (GDPR, UMP)
<!-- meta: size=M; days=2-4; deps=third-party-sdk, paid-service; platform-difference=minor -->
- **Brief:** Consent form for personalised ads, shown by the User Messaging Platform (UMP); the AdMob page names the EEA, UK and Switzerland as test regions.
- **Seen in:** Ad-supported apps (Duolingo, news and game apps).
- **Recommended approach:** UMP through `google_mobile_ads` 9.2.0 (google.dev, published about 9 days before 2026-10-31; Android and iOS). Flow: `ConsentInformation.instance.requestConsentInfoUpdate` at every launch, then `ConsentForm.loadAndShowConsentFormIfRequired`. Rejected: custom dialogs for ad consent.
- **Effort:** M, 2-4 days, driven by message setup and the privacy-options entry point.
- **Depends on:** AdMob account and a message created under Privacy & messaging.
- **Android/iOS differences:** Minor (unverified). The SDK picks the message by the app's AdMob application ID; per-platform ID setup: Verify.
- **Custom work after the package:** Gate ad requests on `canRequestAds()`; show a privacy-options control only when `getPrivacyOptionsRequirementStatus()` says required, opening `showPrivacyOptionsForm`; test with `ConsentDebugSettings` (`testIdentifiers`, `debugGeography`).
- **Pitfalls and store review:** Do not rely on cached consent; remove test identifiers before release; `reset()` is for testing only. After an error the SDK uses the previous session's status.
- **What to tell the requester:** Needed for personalised ads where the message applies; whether it is legally required in your markets: Verify with legal advice.
- **Status:** Partly verified 2026-10-31 from developers.google.com/admob/flutter/privacy and pub.dev/packages/google_mobile_ads. Verify: AdMob application ID setup per platform, legal scope.

### Play Data Safety and Apple privacy labels
<!-- meta: size=S; days=1-2; deps=store-approval; platform-difference=significant -->
- **Brief:** Store disclosures of collected data and sharing.
- **Seen in:** Every store listing.
- **Recommended approach:** Inventory data per SDK, then fill both forms from the same sheet. Xcode's combined SDK manifest report helps with the Apple labels.
- **Effort:** S, 1-2 days.
- **Depends on:** Store consoles. Apple labels are entered in App Store Connect by the Account Holder, Admins or App Managers.
- **Android/iOS differences:** significant: separate forms and wording.
- **Custom work after the package:** Keep forms synced with each release. Apple lets you change label answers at any time without an app update, but answers are required for each new app and update.
- **Pitfalls and store review:** Google counts SDK data and requires a privacy policy; the form is not verified by Google but misstatements risk enforcement. Apple labels must cover data collected by you and third-party partners (SDKs included); data processed only on the device is not "collected"; a public privacy policy URL is required.
- **What to tell the requester:** Mandatory and ongoing.
- **Status:** Verified 2026-10-31 for Apple labels from developer.apple.com/app-store/app-privacy-details and developer.apple.com/support/third-party-SDK-requirements; Play Data Safety verified 2026-10-30 from support.google.com/googleplay/android-developer/answer/10787469.

### Account deletion and age gating
<!-- meta: size=M; days=3-8; deps=backend, store-approval; platform-difference=significant -->
- **Brief:** Users must be able to delete their account in-app; some apps must restrict by age.
- **Seen in:** Instagram, Spotify, TikTok.
- **Recommended approach:** Backend deletion job plus in-app flow and a web deletion link. For age signals, `age_range_signals` 0.10.1 (povhe.si, MIT, not discontinued, pre-1.0) wraps the Play Age Signals API (beta; Android 6.0 or later; needs an access request and a Google Play install) and Apple's Declared Age Range (iOS 26.0 or later; entitlement `com.apple.developer.declared-age-range`; older versions throw `UnsupportedPlatformException`). Play returns age ranges, with signals for Brazil and Texas so far, and may not be used for advertising or analytics.
- **Effort:** M, 3-8 days, driven by data retention and third-party deletion.
- **Depends on:** Backend; store approval.
- **Android/iOS differences:** significant. Apple 5.1.1(v) requires in-app deletion. Google requires an in-app path plus a web link entered in the Data safety form.
- **Custom work after the package:** Everything.
- **Pitfalls and store review:** Cancelling subscriptions first must be explained.
- **What to tell the requester:** Release blocker; ask retention rules.
- **Status:** Verified 2026-10-30 from Apple guidelines and support.google.com/googleplay/android-developer/answer/13327111. Age signals verified 2026-10-31 from pub.dev/packages/age_range_signals, developer.android.com/google/play/age-signals and .../use-age-signals-api. Verify: Apple's Declared Age Range documentation (not opened), age-law scope per region.

### Kids and family compliance
<!-- meta: size=M; days=5-15; deps=backend, third-party-sdk, store-approval; platform-difference=significant -->
- **Brief:** COPPA and GDPR duties, parental gates and restricted SDKs for apps used by children.
- **Seen in:** YouTube Kids, Khan Academy Kids, PBS Kids.
- **Recommended approach:** Decide first whether the app targets children; minimise SDKs and avoid analytics and ads.
- **Effort:** M, 5-15 days, mostly policy and SDK removal.
- **Depends on:** Legal review; store approval.
- **Android/iOS differences:** significant. Apple Kids Category (guideline 1.3): no third-party analytics or advertising, with limited exceptions (analytics that collect no IDFA or identifiable data; contextual ads from services with documented kids policies and human ad review); no personal or device information sent to third parties; links out and purchases only behind a parental gate. Google Families: declare target age groups; apps solely for children must not send the advertising ID or collect precise location; only approved SDKs; Families Self-Certified Ads SDKs and no interest-based ads for children or users of unknown age; mixed-audience apps need a neutral age screen.
- **Custom work after the package:** Parental gate, consent flow, data minimisation. Apple notes a parental gate is not parental consent for data collection.
- **Pitfalls and store review:** Misdeclared audiences lead to removal (Google). Apple reserves "For Kids" wording in metadata for the Kids Category.
- **What to tell the requester:** Get legal advice first.
- **Status:** Verified 2026-10-31 from developer.apple.com/app-store/review/guidelines (1.3, 5.1.4) and support.google.com/googleplay/android-developer/answer/9893335. Verify: COPPA and GDPR specifics (no legal source opened).
