# iOS signing and Fastlane match

Verified 2026-11-04 on Apple's certificate and device pages, Flutter's iOS flavors page and Fastlane's match and register_device pages, unless a line says Unverified. Apple's provisioning-profile overview returned a 404 when opened, so profile details are marked Unverified. Re-check pages older than about two months.

## What each piece is

- **Certificates.** Apple Development (run on devices during development) belongs to an individual. Apple Distribution (distribute to designated devices for testing or submit to App Store Connect) belongs to the team, and the number of distribution certificates per team is capped (check the page for the limit; Unverified here). Only the Account Holder or an Admin can create distribution certificates. [Certificates overview](https://developer.apple.com/help/account/certificates/certificates-overview)
- **Expiry and revocation.** The page gives no validity period (check the expiry date in the developer portal; many teams find it is one year, Unverified). An expired or revoked App Store distribution certificate means you can no longer upload new apps or updates signed with it, and builds already uploaded may be marked Invalid Binary if signed with a revoked one. A revoked or expired in-house certificate stops installed apps from running. An expired APNs certificate stops push sending. Apple may revoke certificates at any time.
- **Provisioning profiles** (Unverified, general knowledge): development and ad hoc profiles tie a certificate, an App ID and a list of registered devices together; an App Store profile has a certificate and an App ID and no device list. A changed certificate or device list means the profile must be regenerated.
- **App ID per flavor.** Each flavor's bundle ID must be registered in your Apple Developer account and in the App ID. [Flutter iOS flavors](https://docs.flutter.dev/deployment/flavors-ios) Enable the capabilities each flavor uses (push, associated domains, Sign in with Apple, In-App Purchase) on its own App ID (Unverified; confirm in the portal).
- **Devices.** Ad hoc and development builds install only on registered devices. Register a UDID under Certificates, Identifiers & Profiles > Devices (Account Holder or Admin); with automatic signing Xcode registers connected devices itself. [Register a device](https://developer.apple.com/help/account/register-devices/register-a-single-device) Per-year device limits and profile regeneration were not covered by the page read (Unverified).

## Xcode flavor setup that signing depends on

[Flutter iOS flavors](https://docs.flutter.dev/deployment/flavors-ios)
- Xcode has no flavors: a flavor is a **shared scheme** plus build configurations named `<Mode>-<flavor>` in lower case (`Debug-staging`, `Profile-staging`, `Release-staging`). The `--flavor` value must equal the scheme name. Schemes that are not shared break flavors.
- Set a different Product Bundle Identifier per configuration, and a per-flavor `APP_DISPLAY_NAME` (used by `CFBundleDisplayName`). Base configurations on `Debug.xcconfig` and `Release.xcconfig`, not `Pods-Runner.xcconfig`.
- If there is a Podfile, add every `<Mode>-<flavor>` configuration to its `project 'Runner'` block (Debug maps to `:debug`, Profile and Release to `:release`) or the CLI may not match configurations.
- Archive uses `Release-<flavor>`; the lane template defaults `BUILD_CONFIGURATION` to that.

## match: one source of certificates

[match](https://docs.fastlane.tools/actions/match/)
- match creates certificates and profiles, stores them encrypted in a private git repository, Google Cloud Storage or Amazon S3, and lets the team and CI reuse them. Git storage needs a repository only trusted people can read; the files are encrypted with a passphrase.
- Types: `development` (default), `adhoc`, `appstore` (also enterprise and Developer ID types). Profile names follow `match <Type> <bundle id>`, for example `match AppStore com.example.app`. Apps share a certificate but get separate profiles; list every flavor's bundle ID in `app_identifier` (comma-separated or an array). One repository can serve all of them. Several teams need one `git_branch` each.
- **`readonly`** fetches and never creates. Use it on CI (`readonly: is_ci`) and for anyone who can read the storage but should not change anything.
- **`MATCH_PASSWORD`** sets the passphrase without a prompt; `fastlane match change_password` changes it. Lose it and the stored files cannot be decrypted.
- With an App Store Connect API key (`api_key`), `offline_profile` cannot be used, and `renew_expired_certs` for Developer ID certificates needs the Account Holder's username and password.
- `force` regenerates profiles on every run. `force_for_new_devices` regenerates profiles when devices were added and is ignored for App Store profiles.
- With several Xcode versions installed, select one before running match (Xcode 16 moved the profile directory).
- `match nuke` revokes certificates and profiles for an environment. Apps already in the App Store or TestFlight keep working; Ad Hoc and Enterprise builds are disabled and need re-uploading. Run it only with the Account Holder's agreement.

## Set up from nothing (once, by an Account Holder or Admin)

1. Register every flavor's bundle ID and its capabilities in the developer portal; create the app records in App Store Connect.
2. Create the private repository for certificates and choose the passphrase; put the passphrase in the team's secret manager.
3. Create the App Store Connect API key (`store-accounts-and-tracks.md`) and put its Key ID, Issuer ID and base64 key content in each env file or the CI secret store.
4. Copy `assets/fastlane/Matchfile` to `ios/fastlane/` and fill the env values.
5. From `ios/` run the `certs_create` lane with `confirm:yes`. It runs match for development, ad hoc and App Store, writing certificates and profiles to the storage:
   `FLUTTER_FLAVOR=staging bundle exec fastlane certs_create confirm:yes`
6. In Xcode, signing for the Release configurations is manual, with the `match <Type> <bundle id>` profile for each flavor. The lane's `update_code_signing_settings` step sets this at build time; setting it once in Xcode as well keeps local archives working.
7. Build a flavor once with the `testflight` lane (or archive in Xcode) before telling anyone it works.

## A new teammate or a new CI machine

1. Give read access to the certificate repository and the passphrase through the secret manager.
2. Put the API key values in their local env file (never in git).
3. Run `FLUTTER_FLAVOR=<flavor> bundle exec fastlane certs_get`: it runs match read-only for all three types and installs the certificates and profiles in the keychain.
4. For development builds on a device, the device UDID must already be registered (below).

## Add a tester device

`FLUTTER_FLAVOR=staging bundle exec fastlane add_device name:"QA iPhone 15" udid:<UDID>` registers the device (the action only adds devices; an existing one is unchanged) and regenerates the ad hoc profile with `force_for_new_devices`. Whether the API key needs an Admin role for registration is not stated on the action's page (Unverified): check the key's role. Then build and upload a new ad hoc build; older builds do not gain the device.

## When something breaks

| Symptom | Look at |
|---|---|
| "No profile matching" or wrong profile name at archive | the flavor's bundle ID missing from `app_identifier`; profile name differs from `match <Type> <bundle id>`; Xcode still on automatic signing |
| Fetch fails on CI | the storage URL or branch; `MATCH_PASSWORD`; read access for the CI key; `readonly` set so it does not try to create |
| New tester cannot install an ad hoc build | device not registered, or the ad hoc profile was not refreshed after adding it |
| Upload rejected after the certificate expired or was revoked | create a new distribution certificate through match, regenerate profiles, rebuild; ask the Account Holder before any `nuke` |
| match asks for Apple ID login | no API key passed, or the key lacks the role |
| Special characters in a password give a misleading "Apple ID or password was entered incorrectly" | use the API key instead of Apple ID login |
