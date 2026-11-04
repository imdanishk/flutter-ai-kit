# Google Maps and Places setup

Verified 2026-11-04 on official pages unless a line says Unverified. Re-check pages older than about two months.

## Before any code

1. **A Google Cloud project with billing enabled.** The Places API (New) setup page says: "Verify that you have a Google Cloud project with billing enabled." Billing belongs to whoever owns the company's Cloud account, not usually the developer. Whether creating the billing account asks for a card was not stated on the pages read (Unverified; in practice it asks for a payment method). [Places setup](https://developers.google.com/maps/documentation/places/web-service/get-api-key?setupProd=enable)
2. **Free usage is per SKU, not a $200 credit.** Since 1 March 2025 each pay-as-you-go SKU has monthly free events by category: 10,000 for Essentials, 5,000 for Pro, 1,000 for Enterprise; Map Tiles API Essentials SKUs get 100,000; the free usage resets on the first of the month at midnight Pacific time. Set budget alerts and quotas in the Cloud console. Read the SKU for each call you plan to use; autocomplete-per-keystroke patterns use events fast. [Billing overview](https://developers.google.com/maps/billing-and-pricing/overview) (page dated 2026-11-02)
3. **Enable each API separately** in that project; picking an API while creating a key does not enable it: "Selecting an API here doesn't enable it." A new enablement can take a few minutes. Disabling unused services at project level blocks them for every key.
   - Maps SDK for Android, Maps SDK for iOS, Maps JavaScript API (web), each only if used. [google_maps_flutter](https://pub.dev/packages/google_maps_flutter)
   - Places API (New) (`places.googleapis.com`). The page covers only the new API; legacy Places has other setup, so do not assume the steps carry over.
4. **Create keys per platform, and restrict them.** [Security best practices](https://developers.google.com/maps/api-security-best-practices)
   - Android key: restrict by package name and SHA-1 signing certificate. Only use a debug certificate for testing and non-production code.
   - iOS key: restrict by bundle identifier.
   - Web key: restrict by referrer, with the whole origin including scheme (`https://*.example.com`).
   - A key with an application restriction cannot be used on other platforms, so one key per platform; if one leaks you rotate only that key.
   - Restrict each key to the APIs it needs. "You are financially responsible for charges caused by abuse of unrestricted API keys."
   - The page does not recommend separate keys per environment; we do: a development key that is leaked or abused should not be the production key. Register each environment's package name or bundle ID and the right SHA values on its own key (see `environments-and-signing.md` for which SHA values: debug, upload, Play app signing).
5. **Keep keys out of the repo.** Do not commit them; for Android the page suggests the Secrets Gradle Plugin. Web-service keys "are not expected to be publicly exposed to unauthorized users or untrusted applications or devices". A Places web-service call made from Dart cannot hide its key inside the app. Decide and state one of: the native Places SDK with a restricted platform key, or a call through your own backend (how to restrict a web-service key used from a mobile client was not confirmed: Unverified).

## Flutter package setup (google_maps_flutter)

- Android key goes in `android/app/src/main/AndroidManifest.xml` as `<meta-data android:name="com.google.android.geo.API_KEY" android:value="..."/>` inside `<application>`. [google_maps_flutter_android](https://pub.dev/packages/google_maps_flutter_android) Read the value from an ignored Gradle property or manifest placeholder, not a literal.
- iOS key goes in `ios/Runner/AppDelegate.swift`: `GMSServices.provideAPIKey("...")` inside `application(_:didFinishLaunchingWithOptions:)`, before `GeneratedPluginRegistrant.register(with: self)`. [google_maps_flutter_ios_sdk10](https://pub.dev/packages/google_maps_flutter_ios_sdk10)
- iOS package choice: the default `google_maps_flutter_ios` is described as legacy and does not support Swift Package Manager; use `google_maps_flutter_ios_sdk10` (Google Maps SDK 10.x, iOS 16 or later) or `google_maps_flutter_ios_sdk9` (iOS 15 or later), added as a dependency in `pubspec.yaml`. Minimums on the package page: Android SDK 24, iOS 15.
- `GoogleMap` must sit in a widget with bounded size; an unbounded parent throws. On Android, `GoogleMapsFlutterAndroid.warmup()` before the first map avoids a first-load jank. On iOS a marker built from `PinConfig` may not show; use an asset or bitmap.

## Symptoms and where to look

| Symptom | Look at |
|---|---|
| Map is grey or blank on one device or build | the key's package name and SHA restriction against that build's SHA (debug vs upload vs Play signing); the Maps SDK is enabled for that platform; the key is in the manifest or AppDelegate of that flavor |
| Works in debug, not in a Play build | the Play app signing SHA-1 is missing from the key restriction |
| Places requests return a permission or billing error | billing enabled on the project; Places API (New) enabled; the key's API restriction includes it |
| Cost surprise | per-SKU events, autocomplete request frequency, no budget alert, unrestricted key |
