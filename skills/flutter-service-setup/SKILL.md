---
name: flutter-service-setup
description: Lists what must exist in consoles and accounts before a Flutter feature can work - per-environment Firebase projects and flavors, SHA fingerprints and signing keys, Google Maps and Places keys and billing, social login, push, and in-app subscriptions on Google Play and the App Store. Use before building or debugging a feature that needs a store, Firebase or Google Cloud setup, or when something works for one developer or build but not another.
license: Apache-2.0
---

# Flutter service setup

Agents write code well and cannot click in consoles. Most lost hours are setup that nobody listed: a missing fingerprint, a billing account, an unsigned agreement. This skill produces that list before the code is written.

## Steps

1. **Name what the task touches.** From the request and the code, pick every row that applies: Firebase (any product), Google sign-in or phone auth, Maps or Places, push notifications, in-app subscriptions or purchases, deep links, a store release.
2. **Open the matching reference** (only those):
   - Firebase projects, flavors, SHA fingerprints, keystores, version pinning: `references/environments-and-signing.md`
   - Maps, Places, API keys and billing: `references/maps-and-places.md`
   - Google sign-in, Sign in with Apple, account deletion: `references/social-login.md`
   - Subscriptions and purchases on Google Play and the App Store: `references/subscriptions-and-iap.md`
   - Store accounts, test tracks, TestFlight and delivery: use the `flutter-release` skill.
3. **Check freshness.** Every reference carries a verified date and source links. If the date is more than about two months before today, open the linked pages, look for changes, and say what changed or that you could not check. Lines marked `Unverified` were not read on an official page: confirm them before telling the developer they are true.
4. **Read the project.** Find the flavors, package names, bundle IDs, existing Firebase files and key handling already in use. Report mismatches instead of fixing them silently (for example a package name that differs between Gradle and Firebase).
5. **Write the setup list** in this form, before or beside the code:

```
Setup before this works
Who: you (developer) / store owner (account holder) / agent (in the repo)
1. [store owner] <step>, why it is needed, how to confirm it is done
2. [you] ...
Per environment: <what must exist once for each of dev, staging, production>
Elapsed-time blockers: <steps that take days, such as identity verification or a review>
Not verified: <items you could not confirm>
```

6. **Do the repo part** only when asked to build the feature: manifest and plist entries, flavor configuration, key placeholders in an ignored file, the Dart code. Never write a real key, keystore or credential into the repo or into the chat.

## Rules

- Split the list by owner. Billing, banking, tax, agreements and identity verification belong to the account holder of the store or cloud account; the developer usually cannot do them.
- State environment scope: what is created once per environment (Firebase project, API keys, store products) and what once per developer (debug keystore fingerprint).
- Say plainly which steps cost money or need a payment method, and which are irreversible (product IDs, signed agreements, package names).
- If a feature works on one machine and not another, check fingerprints and signing first (see `references/environments-and-signing.md`).
