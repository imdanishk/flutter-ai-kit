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
- **Recommended approach:** `passkeys` 2.23.1 (corbado.com, Sep 14, 2026), which needs Flutter 3.35 or later. Alternatives: Auth0 or Supabase built-in passkeys (Supabase marks them beta). The package contains no server; you need a WebAuthn relying-party server.
- **Effort:** M, 5-12 days, mostly backend WebAuthn and recovery flows; the client part is small.
- **Depends on:** Backend WebAuthn server (custom or managed); hosted domain files.
- **Android/iOS differences:** significant. Android: `assetlinks.json` with the `get_login_creds` relation and all signing fingerprints including the Play upload key, served without redirects. iOS and macOS: apple-app-site-association file plus Associated Domains `webcredentials:` entitlement. The relying-party ID must match the domain. Same hosting pattern as App Links in 01-data-sharing-and-linking.md.
- **Custom work after the package:** Registration and sign-in ceremonies, fallback login, credential management screen, account recovery.
- **Pitfalls and store review:** Needs a signed-in Google account and screen lock on Android. Minimum OS versions: Verify.
- **What to tell the requester:** Feasible, but a server is mandatory and a fallback login must remain. Ask whether passkeys replace or supplement passwords.
- **Status:** Verified 2026-10-30 from pub.dev/packages/passkeys and auth0_flutter. OS minimums: Verify.

## Sessions and local protection

### Biometric auth
<!-- meta: size=S; days=1-2; deps=flutter-only, native-android, native-ios; platform-difference=minor -->
- **Brief:** Fingerprint or face check to unlock the app or confirm a sensitive action.
- **Seen in:** Banking apps, WhatsApp chat lock, 1Password.
- **Recommended approach:** `local_auth` 3.0.2 (flutter.dev, Jul 9, 2026). No credible alternative needed.
- **Effort:** S, 1-2 days, driven by fallback and error states.
- **Depends on:** Flutter-only plus platform setup.
- **Android/iOS differences:** Minor. `biometricOnly: true` forces biometrics; by default PIN or pattern is allowed as fallback. Android needs a FragmentActivity-based activity and the biometric permission; iOS needs the Face ID usage description (Verify exact keys in the platform READMEs).
- **Custom work after the package:** Lockout handling, enrolment checks, what happens when biometrics change.
- **Pitfalls and store review:** The result is a boolean on the client, not proof for a server; bind real secrets to a keystore key if needed (Verify).
- **What to tell the requester:** Easy. It is a convenience gate, not server-grade authentication.
- **Status:** Partly verified (version and `biometricOnly` behaviour from pub.dev/packages/local_auth; platform keys: Verify).

### Token refresh and sessions
<!-- meta: size=M; days=2-5; deps=flutter-only, backend; platform-difference=none -->
- **Brief:** Attach access tokens, refresh on 401 once, queue parallel requests, and sign out cleanly when refresh fails.
- **Seen in:** Any app with accounts (Instagram, Uber, Netflix).
- **Recommended approach:** A `dio` interceptor with a single in-flight refresh future, tokens in `flutter_secure_storage` 11.2.0 (steenbakker.dev; default Android storage is RSA-OAEP key wrapping with AES-GCM, min SDK 23). Ferry or GraphQL users do the same in a link. Not verified: current `dio` version.
- **Effort:** M, 2-5 days. Driven by race conditions and multi-device logout.
- **Depends on:** Backend refresh endpoint with rotation.
- **Android/iOS differences:** None in Dart. Keychain data surviving uninstall on iOS: Verify.
- **Custom work after the package:** Everything: queueing, retry policy, forced-logout events, token expiry on app resume.
- **Pitfalls and store review:** Concurrent refreshes invalidating rotated tokens is the classic bug.
- **What to tell the requester:** Achievable; quality depends on backend token design.
- **Status:** Partly verified (flutter_secure_storage only); dio: Verify.

### MFA
<!-- meta: size=M; days=3-8; deps=backend, third-party-sdk, paid-service; platform-difference=minor -->
- **Brief:** Second factor (SMS or authenticator code) at sign-in or for sensitive actions.
- **Seen in:** Google, GitHub, banking apps.
- **Recommended approach:** Use the identity provider's MFA: `firebase_auth` multi-factor, or `auth0_flutter` (MFA supported, verified). Prefer TOTP over SMS. Rejected: custom MFA.
- **Effort:** M, 3-8 days for enrolment, challenge and recovery codes.
- **Depends on:** Provider tier (Firebase SMS MFA needs Identity Platform, Verify), SMS cost.
- **Android/iOS differences:** Minor; SMS auto-fill differs, as in phone OTP.
- **Custom work after the package:** Enrolment UI, challenge screen, backup codes, lost-device support.
- **Pitfalls and store review:** Account recovery is the hard part.
- **What to tell the requester:** Achievable; ask which factors and risk level.
- **Status:** Unverified (Verify): the Firebase MFA page could not be opened.

### Secure PIN / app lock
<!-- meta: size=M; days=3-6; deps=flutter-only; platform-difference=none -->
- **Brief:** In-app lock screen with PIN and optional biometrics after inactivity.
- **Seen in:** WhatsApp, banking and password manager apps.
- **Recommended approach:** `local_auth` 3.0.2 plus `flutter_secure_storage` 11.2.0; store a salted hash of the PIN, never the PIN. Custom lifecycle observer for lock timing.
- **Effort:** M, 3-6 days: lock-on-resume, retry limits, task switcher blur.
- **Depends on:** Flutter-only.
- **Android/iOS differences:** None in logic; hiding the task-switcher snapshot needs native handling on both (Verify).
- **Custom work after the package:** All of it: PIN screens, lockout, forgot-PIN flow, privacy overlay.
- **Pitfalls and store review:** Forgot-PIN must tie back to sign-in.
- **What to tell the requester:** Easy to build; local only, not a server defence.
- **Status:** Partly verified (package pages only).

## Client hardening

### Integrity attestation
<!-- meta: size=M; days=3-7; deps=backend, third-party-sdk, native-android, native-ios; platform-difference=significant -->
- **Brief:** Prove to the backend that requests come from the genuine app on a genuine device.
- **Seen in:** Google apps, banking and game apps.
- **Recommended approach:** `firebase_app_check` 0.5.1 (firebase.google.com, Oct 23, 2026), using Play Integrity on Android and App Attest or DeviceCheck on iOS. Alternative for non-Firebase backends: call the Play Integrity and App Attest APIs through a custom channel.
- **Effort:** M, 3-7 days, driven by backend enforcement and debug-token handling.
- **Depends on:** Firebase or backend verification; Play Console and Apple capability.
- **Android/iOS differences:** significant. Android registers the signing SHA-256; iOS needs the App Attest capability. Providers: Verify, the page did not state them.
- **Custom work after the package:** Server-side token check, staged enforcement, debug providers for CI.
- **Pitfalls and store review:** Rooted or older devices may fail legitimately.
- **What to tell the requester:** Raises the bar; does not stop determined attackers.
- **Status:** Partly verified (version from pub.dev/packages/firebase_app_check; providers: Verify).

### Root, jailbreak and hook detection
<!-- meta: size=M; days=2-5; deps=third-party-sdk, paid-service, native-android, native-ios; platform-difference=minor -->
- **Brief:** Runtime checks for rooted or jailbroken devices, hooking tools and tampering.
- **Seen in:** Banking, payment and game apps.
- **Recommended approach:** `freerasp` 8.2.4 (talsec.app, Oct 5, 2026). It detects root or jailbreak, hooks (Frida, LSPosed) and untrusted installs; freemium with a fair usage policy. Rejected: abandoned single-purpose root checkers.
- **Effort:** M, 2-5 days.
- **Depends on:** Talsec account; commercial tier for more.
- **Android/iOS differences:** Minor; setup values per platform are in Talsec's guide (Verify).
- **Custom work after the package:** Decide the response (warn, limit, block), report to backend.
- **Pitfalls and store review:** False positives block legitimate users; detection can be bypassed.
- **What to tell the requester:** A deterrent, not a guarantee.
- **Status:** Verified 2026-10-30 from pub.dev/packages/freerasp; setup details: Verify.

### Certificate pinning
<!-- meta: size=M; days=1-3; deps=flutter-only, backend; platform-difference=minor -->
- **Brief:** Reject TLS connections whose certificate does not match known fingerprints.
- **Seen in:** Banking apps, Twitter, Signal.
- **Recommended approach:** `http_certificate_pinning` 3.0.2 (softarch.dev, Jul 21, 2026; Dio interceptor, `http` client or direct check), pinning the SHA-256 of an intermediate or public key with a backup pin.
- **Effort:** S-M, 1-3 days, mostly rotation process.
- **Depends on:** Backend certificate operations.
- **Android/iOS differences:** Minor; Android network security config is an alternative (Verify).
- **Custom work after the package:** Pin rotation plan, backup pins, remote kill switch.
- **Pitfalls and store review:** Expired pins brick the app until updated.
- **What to tell the requester:** Doable, but it creates an operational burden; ask who rotates certificates.
- **Status:** Partly verified (pub.dev page only).

### Obfuscation
<!-- meta: size=S; days=0-1; deps=flutter-only; platform-difference=none -->
- **Brief:** Rename Dart symbols in release builds to slow reverse engineering.
- **Seen in:** Banking and game apps.
- **Recommended approach:** `flutter build --obfuscate --split-debug-info=<dir>`; keep the symbols for crash deobfuscation.
- **Effort:** S, under a day plus CI changes.
- **Depends on:** Flutter-only.
- **Android/iOS differences:** None.
- **Custom work after the package:** Store symbols per release and upload to the crash tool.
- **Pitfalls and store review:** Secrets still ship in the binary.
- **What to tell the requester:** Slows analysis only.
- **Status:** Unverified (Verify): Flutter docs page not opened.

## Privacy and compliance

### Privacy manifest (iOS)
<!-- meta: size=S; days=1-2; deps=native-ios, store-approval; platform-difference=significant -->
- **Brief:** `PrivacyInfo.xcprivacy` declares tracking, collected data and required-reason API use for the app and its SDKs.
- **Seen in:** Every App Store app.
- **Recommended approach:** Add the app manifest in Xcode and update plugins to versions that ship their own manifests; Xcode can generate an aggregated privacy report.
- **Effort:** S, 1-2 days, driven by SDK count.
- **Depends on:** Native iOS configuration; store approval.
- **Android/iOS differences:** iOS only, significant.
- **Custom work after the package:** Audit each plugin, match the manifest to the App Store privacy answers.
- **Pitfalls and store review:** Missing manifests or reason codes cause upload warnings or rejection (Verify current enforcement).
- **What to tell the requester:** Mandatory housekeeping.
- **Status:** Unverified (Verify): Apple and Flutter pages did not return the article text.

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
- **Brief:** Consent form for personalised ads in the EU and UK.
- **Seen in:** Ad-supported apps (Duolingo, news and game apps).
- **Recommended approach:** UMP through `google_mobile_ads` 9.2.0 (google.dev, Oct 21, 2026). Rejected: custom dialogs for ad consent.
- **Effort:** M, 2-4 days, driven by message setup in AdMob and a privacy-options entry point.
- **Depends on:** AdMob account and consent message.
- **Android/iOS differences:** Minor; each platform needs its AdMob app ID.
- **Custom work after the package:** Gate ad loading, settings re-entry, testing by debug geography.
- **Pitfalls and store review:** API names: Verify.
- **What to tell the requester:** Required if ads run in the EU.
- **Status:** Partly verified (version only; the AdMob privacy page could not be opened).

### Play Data Safety and Apple privacy labels
<!-- meta: size=S; days=1-2; deps=store-approval; platform-difference=significant -->
- **Brief:** Store disclosures of collected data and sharing.
- **Seen in:** Every store listing.
- **Recommended approach:** Inventory data per SDK, then fill both forms from the same sheet.
- **Effort:** S, 1-2 days.
- **Depends on:** Store consoles.
- **Android/iOS differences:** significant: separate forms and wording.
- **Custom work after the package:** Keep forms synced with each release.
- **Pitfalls and store review:** Google counts SDK data and requires a privacy policy; the form is not verified by Google but misstatements risk enforcement.
- **What to tell the requester:** Mandatory and ongoing.
- **Status:** Verified 2026-10-30 from support.google.com/googleplay/android-developer/answer/10787469; Apple labels: Verify.

### Account deletion and age gating
<!-- meta: size=M; days=3-8; deps=backend, store-approval; platform-difference=significant -->
- **Brief:** Users must be able to delete their account in-app; some apps must restrict by age.
- **Seen in:** Instagram, Spotify, TikTok.
- **Recommended approach:** Backend deletion job plus in-app flow and a web deletion link. For age signals, `age_range_signals` exists on pub.dev; version and maturity: Verify.
- **Effort:** M, 3-8 days, driven by data retention and third-party deletion.
- **Depends on:** Backend; store approval.
- **Android/iOS differences:** significant. Apple 5.1.1(v) requires in-app deletion. Google requires an in-app path plus a web link entered in the Data safety form.
- **Custom work after the package:** Everything.
- **Pitfalls and store review:** Cancelling subscriptions first must be explained.
- **What to tell the requester:** Release blocker; ask retention rules.
- **Status:** Verified 2026-10-30 from Apple guidelines and support.google.com/googleplay/android-developer/answer/13327111; age signals: Unverified (Verify).

### Kids and family compliance
<!-- meta: size=M; days=5-15; deps=backend, third-party-sdk, store-approval; platform-difference=significant -->
- **Brief:** COPPA and GDPR duties, parental gates and restricted SDKs for apps used by children.
- **Seen in:** YouTube Kids, Khan Academy Kids, PBS Kids.
- **Recommended approach:** Decide first whether the app targets children; minimise SDKs and avoid analytics and ads.
- **Effort:** M, 5-15 days, mostly policy and SDK removal.
- **Depends on:** Legal review; store approval.
- **Android/iOS differences:** significant. Apple Kids Category forbids third-party analytics and ads and requires parental gates (verified). Google Families needs certified ad SDKs and a declared age group.
- **Custom work after the package:** Parental gate, consent flow, data minimisation.
- **Pitfalls and store review:** Misdeclared audiences lead to removal.
- **What to tell the requester:** Get legal advice first.
- **Status:** Verified 2026-10-30 from Apple guidelines and support.google.com/googleplay/android-developer/answer/9893335; legal specifics: Verify.
