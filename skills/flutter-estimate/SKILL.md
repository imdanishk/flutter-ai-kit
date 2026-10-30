---
name: flutter-estimate
description: Produces an honest, AI-assisted effort and complexity assessment for a Flutter feature or project, including approach class, custom work after the package, backend dependency, native work, platform differences and risks, as ranges with stated assumptions. Use when asked to estimate, scope, assess feasibility or compare options before building.
license: Apache-2.0
---

# Flutter estimate

An estimate for AI-assisted work measures the developer's attention time, not the time the agent spends typing. Give ranges, state assumptions, and never invent precision.

## Steps

1. **Restate the request** in one or two lines, and name anything undefined that changes the size (platforms, offline support, roles, scale, existing backend, design ready or not). Ask the requester up to five questions only when an answer would change the estimate by more than a day.
2. **Classify each part of the request** with one approach class:
   - Package only
   - Package plus custom work (say what the custom work is)
   - Backend-dependent (say which endpoints, data and jobs the backend must provide)
   - Third-party SDK or vendor (say the vendor, cost model and approval steps)
   - Native code required (say Android, iOS or both)
   - Limited or not realistic on Flutter (say what can be achieved instead)
3. **Check the facts that decide it.** Before recommending a package, check its current version, maintenance, platform support and licence on pub.dev; do not rely on memory. If you cannot check, label the claim unverified. Use the `flutter-feature-notes` skill for the feature, and report the verified date of the entry you used.
4. **Name the Android and iOS differences** that change the work (permissions, background limits, store review, entitlements, extensions) as none, minor or significant.
5. **Estimate with the drivers in `references/estimation.md`.** Give a low to high range of attention time per part and in total. Show the assumptions that would move the range.
6. **Report** in this shape: summary line; table (part, approach class, custom work after the package, backend dependency, Android/iOS difference, range); assumptions; risks and unknowns; questions still open; what you would build first to cut the biggest uncertainty.

## Rules

- A range with its assumptions is the deliverable. A single number is not.
- Say plainly when something is not realistic or depends on a platform owner's approval.
- If the team keeps actual times, tell the requester to compare them with this estimate (see `references/estimation.md`) so the ranges improve.
