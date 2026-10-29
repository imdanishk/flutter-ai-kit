# Estimating AI-assisted Flutter work

The numbers below are starting heuristics, not measurements. Replace them with the team's own actuals as soon as they exist.

## What to estimate

Developer attention time: reading and writing the request, preparing context, reviewing every change, running the app on devices, fixing what the agent got wrong, and any manual platform or store work. Agent running time is cheap and mostly irrelevant.

## Drivers that move the range

| Driver | Smaller range when | Larger range when |
|---|---|---|
| Spec clarity | screens, states and rules are written down | behaviour must be discovered while building |
| Context needed | the feature copies an existing slice | it crosses many modules or has hidden rules |
| Verifiability | result can be checked by running the app quickly | needs real devices, accounts, payments or slow backend flows |
| Novelty and platform risk | well-trodden package, same on both platforms | native code, background work, vendor approval, store policy |
| Supervision and rework | change is local and easy to review | change is wide, subtle or touches security and money |

## Turning drivers into a range

1. Estimate the work as a developer would without an agent (a range).
2. Estimate how much of it is writing code that follows an existing pattern. That part shrinks most with an agent.
3. Keep review, device testing, platform configuration and waiting on other people at full size.
4. Widen the range when more than two drivers sit in the right-hand column.

## Calibrate

Keep a small log: request, estimated range, actual attention time, and what surprised you. After ten entries, replace the heuristics above with the team's own ratios.
