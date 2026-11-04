# Social login and account rules

Verified 2026-11-04 on official pages unless a line says Unverified. Re-check pages older than about two months. For phone auth and passkeys see `flutter-feature-notes`.

## Google sign-in (google_sign_in 7.x)

- Version 7.2.0 was current on pub.dev when checked. It replaced the older API: a `GoogleSignIn.instance` singleton, `initialize`, an `authenticationEvents` stream, and separate `authenticate` and `authorizationClient` calls; the package points to a MIGRATION.md for code written for 6.x or earlier. On web the access token is no longer refreshed and expires after 3600 seconds. [google_sign_in](https://pub.dev/packages/google_sign_in)
- Android: register the app in Firebase or Google Cloud. If `google-services.json` contains a web OAuth client you need not pass ids in Dart; otherwise pass the **web** application's client ID as `serverClientId`. [google_sign_in_android](https://pub.dev/packages/google_sign_in_android)
  - "serverClientId must be provided on Android": check `google-services.json` for an `oauth_client` entry with `client_type: 3`; if missing, add a web app to the Firebase project and download the file again.
  - Causes listed by the package: a missing or wrong signing SHA for one or more build configurations, a wrong package name, a missing or wrong `serverClientId`. A `clientConfigurationError` exception signals a configuration problem; `canceled` after picking an account can also be configuration, because the plugin cannot tell it from the user backing out.
  - SHA values to register for each environment: debug (every developer's, or the shared debug keystore), upload key, and Play app signing key. See `environments-and-signing.md`.
- iOS: enable Google sign-in in Firebase, then download a new `GoogleService-Info.plist`; set `GIDClientID` (the plist's `CLIENT_ID`) and optionally `GIDServerClientID` in `Info.plist`, or pass `clientId` and `serverClientId` in Dart. Add a `CFBundleURLTypes` entry whose scheme is the plist's `REVERSED_CLIENT_ID`; this is needed even when the client ID is set in Dart. The package says not to put the downloaded plist file in your project. [google_sign_in_ios](https://pub.dev/packages/google_sign_in_ios)
- Flavors: neither platform package mentions them. Each environment's Firebase app has its own client IDs and reversed client ID, so the `Info.plist` URL scheme must differ per flavor (Unverified: how to template it per scheme).

## Apple's rules that decide the work

- **Sign in with Apple or an equivalent (guideline 4.8).** An app that uses a third-party or social login (Facebook, Google, X, LinkedIn, Amazon, WeChat) to set up or authenticate the user's primary account must also offer another login option that limits data collection to name and email, lets the user keep the email private, and does not collect app interactions for advertising without consent. The excerpt read did not name Sign in with Apple, which is the usual way to meet it. [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- **Account deletion (5.1.1(v)).** If the app supports account creation it must offer account deletion within the app. The same page says apps without significant account-based features should work without a login.
- Both are review risks the developer should hear about before the login screen is built, not after a rejection.

## Setup checklist to output

For every environment: Firebase app registered for each platform; Google sign-in enabled; web client present; debug, upload and Play-signing SHA-1 and SHA-256 added; iOS plist downloaded after enabling; URL scheme and client ID set per flavor; Apple login added if any other social login exists; in-app account deletion planned.
