---
name: flutter-review
description: Reviews Flutter code changes as a careful senior reviewer and reports findings with file and line, without editing files. Use when asked to review a diff, branch, pull request or a set of Flutter files.
license: Apache-2.0
---

# Flutter review

Read-only. Never modify files while reviewing.

## Steps

1. Get the change: `git diff` against the base branch (or the files named). Also read the project profile in `AGENTS.md` so findings are judged against this project's conventions, not general taste.
2. Read each changed file in full where it matters. Follow calls into the code the change depends on.
3. Check the list below. Report only what you can point to in the code. If you suspect something you cannot confirm, say so and say what would confirm it.
4. Report in this format, most important first:

```
1. <severity: must fix | should fix | consider> <file>:<line> <one-line problem>
   Why it matters: <consequence>
   Fix: <specific change>
```

End with one line listing what you checked and found fine, and one line for anything you could not check.

## Checklist

**Correctness and lifecycle**
- `BuildContext` used after an `await` without `context.mounted`
- state emitted after a cubit or bloc is closed
- loading states with no error path, so a spinner can run forever
- `setState` after dispose; timers, streams, controllers, focus nodes, animation controllers not disposed or cancelled

**Architecture** (against the profile)
- presentation reaching into data code or calling the service locator outside the provider that creates a cubit
- business logic in widgets
- a second way of doing what the project already does (status, results, forms, navigation)

**State and data**
- one status shared by operations that run at the same time
- lists loaded without paging where the data can grow
- equality missing on state classes, so listeners never fire or always fire

**UI**
- user-visible text outside the string table or localization
- non-lazy lists for long data, missing `const`, unbounded widgets that can overflow, text that cannot scale, tap targets without labels

**Platform**
- new permission, deep link, push, camera, location or background feature without the matching Android manifest or iOS `Info.plist` and entitlement changes
- code that works on one platform only and is not guarded

**Security and privacy**
- secrets or tokens in source, tokens in plain preferences, personal data in logs, cleartext HTTP

**Dependencies**
- a new package: is it maintained, does it support every target platform, is the licence acceptable, is it really needed?

**Stack-specific checks** (apply only the one the project profile names)

- Cubit or bloc: a cubit created inside `build` or a `BlocProvider` that recreates it on every rebuild; `context.watch` used in a callback or `context.read` used to render; a `BlocListener` that does what a `BlocBuilder` should draw (or the reverse); state classes without equality; the same cubit instance shared by routes that should not share it.
- Riverpod: `ref.read` inside `build` for values the widget must react to, and `ref.watch` inside callbacks; writing to `state` after an `await` without checking `ref.mounted`; notifier methods called from `build`; one `AsyncValue` shared by operations that run side by side; providers that read `BuildContext`; missing `ProviderScope`; legacy providers (`StateProvider`, `StateNotifierProvider`) in new code; automatic retry left on for calls that must not repeat (payments, one-time actions).

**Generated code**
- generated files edited by hand, or annotated files changed without regenerating
