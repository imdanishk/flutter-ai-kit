---
name: flutter-feature-notes
description: Looks up how a mobile app feature is built in Flutter (recommended package, what the backend must provide, native Android/iOS setup, custom work after the package, store-review risks, effort range and a verified or unverified status). Use when asked whether a mobile feature is feasible, which package or service to use, or what it involves on Android and iOS and in the backend (for example chat, payments, passkeys, live tracking or offline sync). Not needed when the project already has a similar feature to copy.
license: Apache-2.0
---

# Flutter feature notes

Reference notes for planning and building common app features. They are research, not tested code.

## Steps

1. **Find the feature.** The reference files are large: never read one whole. Search `references/index.md` by feature name (for example `grep -i "passkey" references/index.md`). Do not read the whole index. It gives a one-line brief, the usual package and how much Android and iOS differ.
2. **Open the detailed note when one exists.** Find its heading with `grep -n "^### " <area file>` and read only that section. The area files are:
   - `references/auth-security.md`: sign-in, passkeys, biometrics, attestation, pinning, privacy and compliance
   - `references/communication-social.md`: chat, calls, feeds, stories, filters, social features
   - `references/commerce-maps.md`: maps, delivery, booking, live tracking, commerce
   - `references/data-and-platform-surfaces.md`: networking, offline data, sync, home-screen widgets, Live Activities, links and other platform surfaces
   - `references/guides/`: step-by-step setup for data sharing and linking, payments, media and video, notifications, background work and location, AI features inside apps (with evals)
3. **Treat every entry as a dated starting point.** Each entry ends with `Verified <date>`, `Partly verified` or `Unverified (Verify)`. Compare that date with today's date: package versions, prices, store policies and OS rules change within weeks, so an entry older than 30 days is possibly stale, and anything marked Verify is unconfirmed. Before you recommend a package or service:
   - open its current page (pub.dev, official docs, vendor docs) and confirm version, publish date, maintenance, platform support and licence;
   - search for newer or better-maintained alternatives only when the entry is older than 30 days, is marked Verify, or the request differs from it; keep to about five pages in all and say what you did not check;
   - if you would recommend something different from the entry, say so and say why. The entry is not binding.
   Say which claims you confirmed and which you could not.
4. **Report to the requester** using the entry's fields: recommended approach, what depends on the backend or a vendor, native work, Android/iOS differences, custom work after the package, store-review risks and the effort range. Treat the effort range as a starting judgment (see the `flutter-estimate` skill), not a measurement.
5. **If the feature is not covered,** say so, then research it from current official sources (pub.dev, docs.flutter.dev, platform and vendor documentation) and label what you could not verify.

## Rules

- Never present an unverified claim as fact.
- Prefer the single recommended approach in the entry; mention the rejected alternatives only when the requester's situation changes the choice.
- If the project already uses a different package for the same job, follow the project (see `flutter-project-profile`).
- Features that depend on a backend are mostly backend work. Say so, and name what the backend must provide.
