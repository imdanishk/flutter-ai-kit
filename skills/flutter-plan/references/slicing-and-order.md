# Slicing and order

## What a slice is

A thin path through every layer the user touches: screen, state, data, navigation. After it is built it can be run and checked by itself. "Build all screens" and "build the API layer" are layers, not slices.

## Good slice size

- Buildable and checkable in one working session to a few days of the developer's attention, as `flutter-estimate` counts it. If the range is wider than that, split it.
- One user-visible outcome in the goal line ("the user can reset a password"), not a list.
- Acceptance lines someone else could verify without asking you.

## Ordering rules (apply in this order)

1. **Foundation first, but only what slice 1 needs:** project, theme, navigation shell, base types. Do not build every shared widget before a screen needs it.
2. **Riskiest unknown early:** a native SDK, payments, maps, background work, a backend that does not exist yet, a store approval with a long wait. Start the wait early; build the slice when it is unblocked.
3. **Dependencies:** sign-in before anything that needs a user; data a screen reads before the screen that edits it.
4. **Core journey before edges:** the path most users take before settings, profile editing and rare cases. Rare cases still appear in the plan, later.
5. **Ship early:** plan an internal release after the first working journey, not at the end, so store setup problems show up while there is time (`flutter-release`, `flutter-service-setup`).

## When the backend is not ready

Plan the slice against the agreed contract and say what stands in for it (a mock or fake repository behind the same interface the project already uses). Mark the slice "needs backend before release", and list the endpoints in the blockers table. Do not invent endpoint details; ask the backend owner or mark them as proposed.

## When there is no design

Mark the slice "needs design" and plan a design slice before it (`flutter-design`, case C or D). Building screens without a design is allowed only if the developer says so; then say the result will be redone.

## App-wise versus feature-wise

- App-wise plans start with Foundation and end with Ship; between them, slices follow the journeys.
- Feature-wise plans start from the project profile and an exemplar feature, list what the feature reuses, and never include foundation or ship slices unless the feature needs a new service or a store change.

## Re-planning

After each slice, compare what happened with the plan. If a slice took far more than its range, or a risk came true, update the remaining slices and note the change at the top of the plan. A plan that never changes is not being used.
