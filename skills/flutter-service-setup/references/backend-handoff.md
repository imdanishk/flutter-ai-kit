# What to share with the backend, per feature, platform and environment

Verified 2026-11-04 on the pages linked per row unless a line says Unverified. Subscriptions are covered in `subscriptions-and-iap.md` (section "Backend handoff"). Nothing below goes in the repo or in chat: send keys and JSON files through a secret manager. Repeat every row for each environment (development, staging, UAT, production): each has its own Firebase project, its own client IDs, its own bundle ID or package name.

## The rule behind the table

The app proves who the user is by sending a token; the backend checks the token against values it must already know. A wrong value looks like "login works on my build but the server says unauthorized". So for every sign-in or push feature, write down which exact ID the backend checks and who creates it.

## Sign-in

| Feature | The backend needs | Android | iOS | Source |
|---|---|---|---|---|
| Google sign-in (the app sends a Google ID token) | The **Web** client ID of every client that sends it tokens; it must equal the token's `aud`. Check also `iss` (`accounts.google.com`), expiry and signature with a Google or JWT library; use `sub` as the user key, not email. A library such as Python's does not check several `aud` values for you. | Pass the same web client ID as `serverClientId` (or have a web client in `google-services.json`, `client_type: 3`); Android needs the SHA values registered | Set `GIDServerClientID` (or `serverClientId`) to the same web client ID | [Google backend verification](https://developers.google.com/identity/sign-in/web/backend-auth), [google_sign_in_android](https://pub.dev/packages/google_sign_in_android) |
| Firebase Authentication (phone, email, or social through Firebase) | The Firebase **project ID** and a service account for the Admin SDK; `verifyIdToken()` checks the token is well formed, unexpired and signed, but not revoked unless you check revocation separately. In a multi-environment backend make sure each environment resolves the right project (a stray `GOOGLE_CLOUD_PROJECT` or the wrong service account would point it at another project: inference). | SHA-1 and SHA-256 registered for phone auth | APNs key and push capability for phone auth | [Verify ID tokens](https://firebase.google.com/docs/auth/admin/verify-id-tokens) |
| Sign in with Apple | Second-hand, Unverified (Apple's page had no body text): the Team ID, the Key ID and `.p8` key of a Sign in with Apple key (the backend builds an ES256 client secret from them), and the client ID: bundle ID for native iOS, Services ID for web or Android flows. The backend validates the identity token against Apple's public keys (`iss`, `aud`, `exp`, nonce) and uses `sub` as the user key. Details in `social-login.md`. | Android uses the web flow, so needs a Services ID and a redirect URL (Unverified) | Capability on the App ID | [Guidelines 4.8](https://developer.apple.com/app-store/review/guidelines/), [REST API](https://developer.apple.com/documentation/signinwithapplerestapi) |
| Facebook | Second-hand, Unverified (Meta's page could not be opened): the Meta App ID and App Secret per environment, so the backend can check the user's access token with Meta rather than trust the app. The app itself holds the App ID and Client Token. Details in `social-login.md`. | Package name, main activity and a key hash per signing key registered in the Meta app | Bundle ID registered; URL scheme and plist keys | [Meta docs](https://developers.facebook.com/docs/facebook-login) |
| Other providers | Unverified: the provider's app ID and secret, and the redirect or key-hash settings per platform. Look up the provider's current docs. | provider-specific | provider-specific | none opened |

## Push notifications

- **Firebase Cloud Messaging.** The backend sends with the HTTP v1 API at `https://fcm.googleapis.com/v1/projects/<project id>/messages:send`, authorized with a short-lived OAuth token for the scope `https://www.googleapis.com/auth/firebase.messaging`; the Admin SDK does the token handling. On a server outside Google Cloud it needs a **service account JSON key** (set `GOOGLE_APPLICATION_CREDENTIALS`); sending across projects needs the *Firebase Cloud Messaging API Admin* role in the target project. So hand over, per environment: the Firebase project ID and a service account key. [FCM server auth](https://firebase.google.com/docs/cloud-messaging/auth-server)
- The app gives the backend each device's FCM token (an API call you design); the backend stores it per user and per environment.
- **iOS:** upload an **APNs authentication key** (and its key ID) in the Firebase console, in the Cloud Messaging tab of the project settings; a development key, a production key or both, at least one is required. The backend does not need the APNs key when it sends through FCM (inference); the key lives in Firebase, one upload per Firebase project. [APNs key](https://firebase.google.com/docs/cloud-messaging/ios/certs)
- An expired APNs certificate (if one is used instead of a key) stops push sending. [Apple certificates](https://developer.apple.com/help/account/certificates/certificates-overview)

## Maps and Places

- Mobile keys are restricted to one platform (Android: package name plus SHA-1; iOS: bundle ID) and cannot be reused elsewhere; the backend must **not** reuse them. [API key best practices](https://developers.google.com/maps/api-security-best-practices)
- If the backend calls a Maps web service (geocoding, places lookups), create a separate key for it, restrict it to the APIs it calls, and keep it in the backend's secret store. How to restrict a web-service key by server address was not confirmed (Unverified; check the page above).
- Billing and the project belong to the company's Cloud account: see `maps-and-places.md`.

## Deep links, app links and passkeys (the backend or web team hosts the files)

- **Android:** `https://<domain>/.well-known/assetlinks.json` with the package name and the SHA-256 of every signing certificate that will be installed (Play app signing key; the upload key if you sideload release builds; one entry per flavor package name). Served with HTTP 200 as `application/json` and no redirect.
- **iOS:** `https://<domain>/.well-known/apple-app-site-association` listing `<Application Identifier Prefix>.<Bundle Identifier>` (the prefix is the Team ID) for each flavor's bundle ID; each subdomain needs its own file; devices fetch it through Apple's network and recheck about weekly, so changes are not instant.
- Passkeys use the same hosted files plus the relying-party ID (the domain name). Details and sources: `flutter-feature-notes` (data sharing and linking, auth and security).
- Hand the web team, per environment: package name, SHA-256 fingerprints, bundle ID, Team ID, and the domain each environment uses.

## Subscriptions

Service account key, package name and topic (Google); In-App Purchase key, Key ID, Issuer ID, shared secret if used, bundle ID and notification URLs (Apple). See `subscriptions-and-iap.md`.

## What the backend gives the app

Per environment: the API or GraphQL endpoint URL; the notification endpoint URLs for the stores; the OAuth redirect or callback URLs it registered; the product IDs it expects; and which client IDs it accepts. Record them in the project's setup list, not in the repo if they are secret.

## One-page hand-off sheet to fill per environment

```
Environment: ______   Backend URL: ______
Android package: ______   iOS bundle ID: ______   Team ID: ______
Firebase project ID: ______   Service account (secret manager ref): ______
Google web client ID: ______   (Android/iOS client IDs registered: yes/no)
Sign in with Apple: Services ID ______  Key ID ______  (key file in secret manager)
Facebook: Meta App ID ______  (secret and client token in secret manager)
APNs key uploaded to Firebase: yes/no (key ID ______)
Maps keys: Android ______ iOS ______ (names only, not values)   Backend web-service key: yes/no
App links: SHA-256 (Play signing) ______  (upload) ______   AASA file live: yes/no
Play: service account, topic, test message ok: yes/no
Apple: IAP key ID ______  Issuer ID ______  notification URLs set: yes/no
```
