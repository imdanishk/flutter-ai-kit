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

## Facebook login (flutter_facebook_auth) — second-hand, Unverified

Everything in this section came from a developer's pasted setup text and general knowledge. Meta's and pub.dev's pages could not be opened here, so none of it is verified. Open both pages and check the package version and SDK versions before relying on it: [package](https://pub.dev/packages/flutter_facebook_auth), [Meta docs](https://developers.facebook.com/docs/facebook-login).

- **Meta console:** create the app, add the Facebook Login product, and copy the **App ID** and the **Client Token** (Settings > Advanced). One Meta app per environment keeps IDs and review state separate (our recommendation).
- **Android:** two `<meta-data>` entries in `AndroidManifest.xml` (`com.facebook.sdk.ApplicationId` and `com.facebook.sdk.ClientToken`) pointing at string resources, with the values in `strings.xml`. With flavors, put the strings in each flavor's own `res/values/` folder.
- **iOS:** in `Info.plist`: `FacebookAppID`, `FacebookClientToken`, `FacebookDisplayName`, a `CFBundleURLSchemes` entry `fb<APP_ID>`, and `LSApplicationQueriesSchemes` with `fbapi` and `fb-messenger-share-api`. The URL scheme and IDs differ per flavor, as with Google.
- **Web:** the pasted text loads the JavaScript SDK in `web/index.html` with a pinned `version: 'v18.0'`. That version looks old; take the current one from Meta's docs.
- **Code:** `FacebookAuth.instance.login(permissions: ['email', 'public_profile'])`, then check `result.status == LoginStatus.success`. Do not print the token.
- **Not in the pasted text; general knowledge, Unverified, check on Meta's pages:**
  - Android needs the app's package name, main activity and **key hash** registered in the Meta app, for each signing key (debug, upload, Play signing), the same mismatch trap as SHA-1.
  - iOS needs the bundle ID registered in the Meta app.
  - A Meta app in development mode only lets the app's own testers and roles log in. Real users need the app switched to Live, a privacy policy URL, and App Review for any permission beyond the basics.
  - Meta asks for a data deletion callback or instructions URL; this ties to the account-deletion rules below.
  - On iOS, Meta has a Limited Login mode used when the user declines tracking; the package may need extra code for it.
- Backend: see the Facebook row in `backend-handoff.md`. Ask the backend to validate the token with Meta server-side rather than trust the app.

## Apple's rules that decide the work

- **Sign in with Apple or an equivalent (guideline 4.8).** An app that uses a third-party or social login (Facebook, Google, X, LinkedIn, Amazon, WeChat) to set up or authenticate the user's primary account must also offer another login option that limits data collection to name and email, lets the user keep the email private, and does not collect app interactions for advertising without consent. The excerpt read did not name Sign in with Apple, which is the usual way to meet it. [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- **Account deletion (5.1.1(v)).** If the app supports account creation it must offer account deletion within the app. The same page says apps without significant account-based features should work without a login.
- **Google Play has its own deletion rule:** an in-app deletion path plus a web link entered in Play Console, and the Data deletion answers in the Data safety form (see `flutter-release/references/store-accounts-and-tracks.md`).
- These are review risks the developer should hear about before the login screen is built, not after a rejection.

## Sign in with Apple, server side — second-hand, Unverified

Apple's REST API page ([Sign in with Apple REST API](https://developer.apple.com/documentation/signinwithapplerestapi)) returned no body text here, so the following is a developer's description plus general knowledge, consistent between the two but not read on an official page. Check the page before use.

- **Apple Developer side:** enable Sign in with Apple on the App ID; create a Sign in with Apple **key** (gives a Key ID and a `.p8` file, downloadable once); note the Team ID. A Services ID is the client ID for web and Android flows; the bundle ID is the client ID for native iOS.
- **Client secret:** the backend generates a JWT signed with ES256 using the `.p8` key. Header `kid` = Key ID. Claims: `iss` = Team ID, `iat`, `exp` (no more than about six months after `iat`), `aud` = `https://appleid.apple.com`, `sub` = the client ID.
- **Token exchange:** `POST https://appleid.apple.com/auth/token` with the client secret and the authorization code.
- **Identity token check:** fetch Apple's public keys from `https://appleid.apple.com/auth/keys`, match `kid`, verify the signature, then check `iss` (`https://appleid.apple.com`), `aud` (your client ID), `exp`, and the nonce if one was sent. Use `sub` as the stable user key.
- **Name and email:** the name arrives only on the first authorization, so save it then. The email may be a private relay address.
- **Account deletion:** call `https://appleid.apple.com/auth/revoke` with the user's token when they delete their account (ties to guideline 5.1.1(v) above).
- Never put the `.p8` file in git; it goes in the backend's secret manager.

## Setup checklist to output

For every environment: Firebase app registered for each platform; Google sign-in enabled; web client present; debug, upload and Play-signing SHA-1 and SHA-256 added; iOS plist downloaded after enabling; URL scheme and client ID set per flavor; Apple login added if any other social login exists; in-app account deletion planned.
