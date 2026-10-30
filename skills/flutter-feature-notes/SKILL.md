---
name: flutter-feature-notes
description: Looks up how a mobile app feature is built in Flutter (recommended package, what the backend must provide, native Android/iOS setup, custom work after the package, store-review risks, effort range and a verified or unverified status). Use when asked whether a feature is feasible, how to build it, or what it involves, such as sign-in, chat, maps, payments, notifications or offline data.
license: Apache-2.0
---

# Flutter feature notes

Reference notes for planning and building common app features. They are research, not tested code.

## Steps

1. **Find the feature.** Search `references/index.md` by feature name (for example `grep -i "passkey" references/index.md`). Do not read the whole index. It gives a one-line brief, the usual package and how much Android and iOS differ.
2. **Open the detailed note when one exists.** Search the area files for the feature name:
   - `references/auth-security.md`: sign-in, passkeys, biometrics, attestation, pinning, privacy and compliance
   - `references/communication-social.md`: chat, calls, feeds, stories, filters, social features
   - `references/commerce-maps.md`: maps, delivery, booking, live tracking, commerce
   - `references/data-and-platform-surfaces.md`: networking, offline data, sync, home-screen widgets, Live Activities, links and other platform surfaces
   - `references/guides/`: step-by-step setup for data sharing and linking, payments, media and video, notifications, background work and location
3. **Check the status line of the entry before relying on it.** Each entry ends with `Verified <date>`, `Partly verified` or `Unverified (Verify)`. Package versions, prices, store policies and OS rules change within weeks. If the entry is older than about a month, or any part says Verify, open the current package page or policy page and confirm before you recommend it. Say which claims you confirmed and which you did not.
4. **Report to the requester** using the entry's fields: recommended approach, what depends on the backend or a vendor, native work, Android/iOS differences, custom work after the package, store-review risks and the effort range. Treat the effort range as a starting judgment (see the `flutter-estimate` skill), not a measurement.
5. **If the feature is not covered,** say so, then research it from current official sources (pub.dev, docs.flutter.dev, platform and vendor documentation) and label what you could not verify.

## Rules

- Never present an unverified claim as fact.
- Prefer the single recommended approach in the entry; mention the rejected alternatives only when the requester's situation changes the choice.
- If the project already uses a different package for the same job, follow the project (see `flutter-project-profile`).
- Features that depend on a backend are mostly backend work. Say so, and name what the backend must provide.
