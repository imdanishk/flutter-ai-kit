# Store accounts, test tracks and delivery

Verified 2026-11-04 on official pages unless a line says Unverified. Re-check pages older than about two months.

## Google Play

**Account.** [Verification requirements](https://support.google.com/googleplay/android-developer/answer/10841920)
- Personal: an official government ID, and proof of access to a real Android device (required before the app can go live).
- Organization: government ID, an official organization document, a D-U-N-S number (applying through Dun & Bradstreet is free; beware paid third parties) and website verification. Government bodies can request an exception.
- Contact email and phone, and a developer email and phone (organizations), are each verified with a 6-digit code. Verify before submitting apps; Play Console lets you do it up to 60 days before your own deadline. Unverified accounts can have apps removed.
- The registration fee was not stated on the pages read (Unverified).

**Before production, personal accounts.** Accounts created after 13 November 2023 need a closed test with at least 12 testers opted in continuously for 14 days, then "Apply for production" in the Dashboard; review usually takes up to seven days. [Testing requirements](https://support.google.com/googleplay/android-developer/answer/14151465)

**Target API.** New apps and updates must target Android 16 (API 36) from 31 August 2026 (an extension to 1 November 2026 was offered, and that date has now passed); existing apps must target API 35 or higher to stay available to new users. Check the page for the current number when you start. [Target API](https://support.google.com/googleplay/android-developer/answer/11926878)

**Signing.** Use Play App Signing; sign uploads with an upload key. See `flutter-service-setup/references/environments-and-signing.md` for the three fingerprints and what to register where.

**First upload is manual.** Fastlane `supply` cannot connect to an app until at least one build has been uploaded through Play Console. [upload_to_play_store](https://docs.fastlane.tools/actions/upload_to_play_store/)

**Service account for Fastlane.** Note the Google Cloud project ID under Account details in Play Console; enable the Google Play Developer API in that project; create a service account (JSON key, or Workload Identity Federation in GitHub Actions); invite its email in Play Console under Users and permissions (Admin is recommended; Releases permissions such as releasing to production can be left out); test with `validate_play_store_json_key`. Treat the JSON like a password.

**Tracks.** `internal`, `alpha` (closed), `beta` (open), `production`. Fastlane's default track is `production`; always pass the track. `release_status` is `completed`, `draft`, `halted` or `inProgress`; use `draft` to finish the release in the console. A staged rollout uses `rollout` as a fraction. Before a release can be sent for review, Play Console's App content page (Monitor and improve > Policy and programs > App content) needs: a privacy policy linked on the store listing and inside the app (a public, login-free, standard web page with a valid SSL certificate, not a PDF); the ads declaration; app access instructions when any part of the app needs a login (up to five sets); the target age group (children's apps must meet the Families policy); a permissions declaration for sensitive permissions; the content-rating questionnaire (unrated apps can be removed); and the **Data safety form**. Changes are sent through Publishing overview > Send for review. [Prepare your app for review](https://support.google.com/googleplay/android-developer/answer/9859455)
- **Data safety form:** required for every app published on a closed, open or production track (internal-testing-only apps are exempt). It lists the data types collected or shared (including by third-party SDKs), why, whether each is optional, whether data is encrypted in transit, and whether users can request deletion. One form applies per package name, so each flavor with its own package needs its own. You are responsible for its accuracy; inaccurate answers can block a submission or lead to removal. Keep it current when SDKs or data practices change. [Data safety](https://support.google.com/googleplay/android-developer/answer/10787469)
- **Account deletion:** an app that lets users create an account must offer an in-app deletion path and a web link where they can request deletion (the link is entered in Play Console and must name the app or developer as shown on Google Play); the Data deletion questions in the Data safety form must be answered or submissions and updates are rejected. [Account deletion](https://support.google.com/googleplay/android-developer/answer/13327111)

**Fastlane traps.** `skip_upload_metadata` does not cover changelogs or images; screenshots replace existing ones; changelog files are named by version code; bundles over 150 MB need `ack_bundle_installation_warning`.

## Apple (App Store Connect and TestFlight)

**Requirements with dates.** [Upcoming requirements](https://developer.apple.com/news/upcoming-requirements/)
- Since 28 April 2026 apps must be built with Xcode 26 or later and the SDK for iOS 26 (and iPadOS, tvOS, visionOS, watchOS 26).
- The page lists a 9 September 2026 requirement that iOS and iPadOS apps uploaded to App Store Connect target iOS 13 or later.
- Updated age-rating questions had to be answered by 31 January 2026.
- Privacy manifests with approved reasons for required-reason APIs, including those used by third-party SDKs, since 1 May 2024; EU apps need verified trader status (DSA).

**App record and roles.** Register the bundle ID, then create the app in App Store Connect. Uploading a build works with the Developer role; changing build info and testers needs App Manager or Admin. [upload_to_testflight](https://docs.fastlane.tools/actions/upload_to_testflight/)

**API key for automation.** An Admin creates it in App Store Connect under Users and Access > Integrations > App Store Connect API > Team Keys: name, role, Generate. The private key (`.p8`) downloads once, so store it at once in a secret manager; never commit it. You also need the Key ID and the Issuer ID (the Issuer ID is not on the key-creation page read; a team's hand-off guide says it is shown above the Active keys table on the Integrations page: Unverified officially). An API key avoids two-factor prompts, which Apple ID login does not. [Creating API keys](https://developer.apple.com/documentation/appstoreconnectapi/creating-api-keys-for-app-store-connect-api)

**Signing.** TestFlight and App Store builds need a **distribution** certificate, not a development one. [Flutter CD](https://docs.flutter.dev/deployment/cd) Fastlane `match` stores certificates and profiles in a private git repo, Google Cloud Storage or S3, encrypted; use `readonly: is_ci` on CI so a pipeline never creates new certificates; `MATCH_PASSWORD` decrypts the git storage and losing it means losing the stored files; `match nuke` revokes certificates (Ad Hoc and Enterprise builds stop working; store apps keep working). List every flavor's bundle ID in `app_identifier`; apps share the distribution certificate but get separate profiles. With several Xcode versions installed, select one before `match` (Xcode 16 moved the profile directory). [match](https://docs.fastlane.tools/actions/match/)

**TestFlight.** [Overview](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview)
- Internal testers: up to 100 App Store Connect users. External testers: up to 10,000 people, by email or public link.
- The first build added to an external group goes to Beta App Review; later builds may not need a full review. Testing starts when the build is approved.
- A build is testable for 90 days. Provide beta app description, features to test and a feedback email before testing starts.
- Builds must include application identifiers within the provisioning profiles to be eligible.
- Export compliance: set `ITSAppUsesNonExemptEncryption` in `Info.plist`, or Fastlane's `uses_non_exempt_encryption` supplies the answer when the key is missing (default `false`: answer honestly for your app).
- `skip_waiting_for_build_processing: true` saves CI minutes but means no external distribution from that run; with a changelog, Fastlane still waits until the build appears so the text can be set (Fastlane source, read 2026-11-05).
- Passwords with special characters can produce a misleading "Apple ID or password was entered incorrectly" error; prefer the API key.
- Apps from TestFlight always run in the sandbox for purchases (see `flutter-service-setup/references/subscriptions-and-iap.md`).

## Firebase App Distribution

[Fastlane setup](https://firebase.google.com/docs/app-distribution/android/distribute-fastlane)
- Install the plugin: `fastlane add_plugin firebase_app_distribution` in the platform folder (choose RubyGems when asked).
- Authenticate with a service account that has the **Firebase App Distribution Admin** role (`service_credentials_file` or `GOOGLE_APPLICATION_CREDENTIALS`), or the Firebase CLI sign-in (`firebase_cli_token` on CI). The page does not say whether the CLI token method is deprecated: check the Firebase CLI docs before using it. A service account key grants admin access; store it securely.
- `app` is the Firebase App ID, not the package name. `groups` takes group aliases from the console, not display names; testers and groups are comma-separated, test devices semicolon-separated.
- Download links expire after one hour; builds stay 150 days; tester invitations expire after 30 days.
- An iOS ad hoc build only installs on devices whose UDIDs are in the provisioning profile (Unverified; the iOS page was not read). Register devices, then refresh the profile with `match`.
