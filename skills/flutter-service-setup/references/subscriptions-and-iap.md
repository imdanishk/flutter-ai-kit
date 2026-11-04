# Subscriptions and in-app purchases (Google Play and App Store)

Verified 2026-11-04 on official pages unless a line says Unverified or "community". Re-check pages older than about two months. Output the setup list split by owner: the store account holder does agreements, banking, tax and identity; the developer does products, code and testing.

## Order of work

1. Store accounts exist and are verified (see the `flutter-release` skill, `store-accounts-and-tracks.md`).
2. Agreements and payments profiles are active (account holder).
3. A build that includes the billing library is uploaded (Google), the app record exists (Apple).
4. Products are created: subscription, then base plan and offers (Google); subscription group, then subscriptions (Apple).
5. Test accounts and test tracks are ready.
6. Only then write and test the purchase code and the server checks.

Product IDs cannot be changed or reused on either store. Decide naming and the plan structure with the business owner first, and keep one ID scheme across both stores.

## Google Play

- **Payments profile.** Selling needs a profile in the Google Payments Center linked to the developer account; the developer account alone is not enough. [Billing: getting ready](https://developer.android.com/google/play/billing/getting-ready) Where payout and bank details are entered is not stated on that page (Unverified).
- **Upload a build first.** Billing features in Play Console, including product setup, are enabled only after a build with the Play Billing Library is uploaded to any track, internal testing included. Purchases from draft apps and the internal track are subject to spend limits; closed, open or production tracks have higher limits. [Testing](https://developer.android.com/google/play/billing/test)
- **Library version.** The page says all new apps and updates must use Billing Library 8 or later from 31 August 2026 (an extension to 1 November 2026 was offered), and its example uses 9.1.0. Check the current version in the package you use (for example `in_app_purchase_android`) before starting.
- **Create in this order:** subscription, base plan, offers. [Create subscriptions](https://support.google.com/googleplay/android-developer/answer/140504)
  - Product ID: up to 40 characters, starts with a number or lowercase letter, cannot be changed or reused. Name: up to 55 characters. Up to four benefits of up to 40 characters, with no price or free-trial wording.
  - Base plan: auto-renewing, prepaid, or installments (Brazil, France, Italy, Spain only). Set regions, enter tax-exclusive prices, then **Save and Activate**: a base plan must be active before users can buy.
  - Offers belong to one base plan; free trials last 3 days to 3 years; eligibility is new customers, upgrades, or developer-determined.
  - Once a base plan exists the subscription cannot be deleted, only archived. Removing a region means removing it from all offers first.
  - The app must clearly show offer terms, cost and how to cancel.
- **Server and notifications (if the backend validates purchases).** Grant the service account the **View financial data** permission. Real-time developer notifications need a Pub/Sub topic (`projects/{project_id}/topics/{name}`), the Pub/Sub Publisher role for `google-play-developer-notifications@system.gserviceaccount.com`, and enabling notifications under Monetize > Monetization setup; configure each app separately. A notification only says the state changed; call the Play Developer API for the full state. Domain-restricted sharing needs an exception for that service account.
- **Test.**
  - Add license testers in Play Console (setup page: "Test in-app billing with application licensing"; the menu path was not on the page read: Unverified). The tester's Google account must be on the device, and the app must be installed from a test track after the tester opts in; availability can take a few hours.
  - Test instruments: always approves, always declines, slow approve, slow decline, approves then charges back. Real users incur real charges on test tracks unless they are license testers.
  - Test subscriptions renew fast (a monthly plan every 5 minutes, yearly every 30 minutes), at most six renewals; free trial 3 minutes, grace 5 minutes, account hold 10 minutes.
  - Acknowledge every purchase: a license-tester purchase is refunded after 3 minutes if the app does not acknowledge it. Resubscribe and pause are always on for license testers even if disabled in the console.
  - Billing Lab settings expire after 2 hours; clear the Play Store cache if changes do not appear; do not use real payment methods without Google's agreement.
- **Personal developer accounts** created after 13 November 2023 must run a closed test with at least 12 testers opted in continuously for 14 days before applying for production access; review usually takes up to seven days. A subscription app should plan this into the schedule. [Testing requirements](https://support.google.com/googleplay/android-developer/answer/14151465)

## App Store

- **Paid Apps Agreement.** "To sell your apps on the App Store or offer In-App Purchases, the Account Holder must sign the Paid Apps Agreement" (Business > Agreements > Paid Apps > View and Agree to Terms). Until the latest version is agreed you cannot create a new app or In-App Purchase, and it must be active to submit or update paid apps and In-App Purchases; signing cannot be undone and must be repeated after a membership renewal. Banking and tax information are separate sections of Business; the agreement page does not list them as prerequisites, so check their status on the Agreements tab (Unverified). [Agreements](https://developer.apple.com/help/app-store-connect/manage-agreements/sign-and-update-agreements)
- **Create:** under Monetization > Subscriptions, create a **subscription group** (one group is best practice for most apps; up to 100 subscriptions per group), then subscriptions with a reference name, product ID, duration (1 week to 1 year), price, availability, and under Review Information a screenshot and review notes. Roles that can do this: Account Holder, Admin, App Manager, Developer, Marketing. [Offer subscriptions](https://developer.apple.com/help/app-store-connect/manage-subscriptions/offer-auto-renewable-subscriptions)
- **Missing Metadata.** Community answer (Apple developer forum, not Apple documentation): a subscription group with no localized display name keeps every subscription in "Missing Metadata" however complete each one is. Also check: prices for all countries, availability, the review screenshot, localization of each subscription, signed agreements, and the In-App Purchase capability in Xcode. [forum thread](https://developer.apple.com/forums/thread/778561)
- **Submission with the app (Unverified).** Apple's submission page could not be opened. In practice the first subscription is attached to an app version when that version is submitted; later subscriptions can be submitted separately. Confirm in App Store Connect before promising a date. Metadata changes can take up to an hour to reach sandbox.
- **Guidelines that shape the screen.** Unlocking features must use In-App Purchase, with a restore mechanism for restorable purchases (3.1.1). A subscription must give ongoing value, last at least seven days, work across all of the user's devices, and the app must clearly describe what the user gets for the price (3.1.2). [Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- **Receipts.** Apps that validate receipts on the device must support the SHA-256 intermediate certificate, or use the `AppTransaction` and `Transaction` StoreKit APIs. [Upcoming requirements](https://developer.apple.com/news/upcoming-requirements/)
- **Test with sandbox.** Create Sandbox Apple Accounts in App Store Connect (menu path not read: Unverified). A sandbox account only works for apps under the same Apple Developer Program account. Apps installed from TestFlight always run in the sandbox. To use the sandbox account on the device: sign out of the production account in Settings > Media & Purchases, then sign in under Settings > Developer > Sandbox Apple Account (Developer Mode must be on). Signing out can remove access to purchased content, so use a dedicated test device. [Sandbox testing](https://developer.apple.com/documentation/storekit/testing-in-app-purchases-with-sandbox)
- Local StoreKit configuration files in Xcode test without App Store Connect; their details were not read (Unverified).

## Both stores

- Each store's products must be configured separately; the IDs may differ per environment build. Decide whether development and staging builds use the real products or separate test products. A flavor with its own `applicationIdSuffix` is a different app to the store, so it needs its own app record and products before it can load any (inference from how stores key products to the app ID; confirm when setting up).
- The user must be able to restore purchases and to see the price, period and renewal terms before paying.
- Server-side validation and state sync (webhooks or notifications) are a backend task: say so in the setup list.
