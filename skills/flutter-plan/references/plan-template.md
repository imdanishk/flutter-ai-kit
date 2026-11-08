# Plan template

Copy the shape, drop what does not apply. Keep each slice under about fifteen lines.

```markdown
# Plan: <app or feature name>

Scope: app-wise | feature-wise. Date: <date>. Based on: <brief, design link, profile>.

## Assumptions and open questions
- Assumed: <platforms, roles, offline, backend owner, design status>
- Open: <question that would change the order or size>

## Flows
<one Mermaid diagram per flow, see flows-and-journeys.md>

## Slices (in build order)

### 0. Foundation (app-wise only)
Goal: project builds on both platforms with theme, navigation shell, base types, flavours if the project uses them.
Skills: `flutter-new-project`, `flutter-project-profile`. Waits on: <store or Firebase accounts if they gate step 1>.
Done when: app launches on Android and iOS, analyzer is clean, profile is in `AGENTS.md`.

### 1. <Slice name, e.g. Sign in with email>
Goal: <one sentence, the user can ...>
Screens and states: <screens; loading, error, empty as needed>
Data and API: <endpoints or local storage; who provides them; contract known? yes/no>
Services and native: <keys, consoles, permissions, entitlements; see `flutter-service-setup`>
Design needs: <provided / needs design (flutter-design) / uses existing components>
Done when: <observable checks, e.g. "wrong password shows the field error and keeps the typed email">
Risks: <what could change the plan>
Size: <small | medium | large, or the range from `flutter-estimate`>
Skill: `flutter-feature`

### N. Ship
Goal: internal testers can install it.
Skills: `flutter-release`, `flutter-service-setup`, `flutter-store-assets` (on request).
Waits on: store accounts, closed test requirements, App Review (elapsed time, not effort).

## Blockers that are not build effort
| Blocker | Owner | Needed before slice | Elapsed time known? |
|---|---|---|---|

## Not in this plan
<things deliberately left out, so nobody assumes they are included>
```

## Checks before showing the plan

- Every slice can be run and checked alone, and has an acceptance line someone else could verify.
- Every external need (backend, key, account, approval, design) appears in a slice and in the blockers table.
- The riskiest unknown is in the first two slices, or the plan says why not.
- Nothing in the plan assumes a package, endpoint or store rule that was not checked; unchecked items are labelled.
