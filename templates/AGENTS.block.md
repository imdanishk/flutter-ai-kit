<!-- flutter-ai-kit:start v__VERSION__ -->
## Flutter working rules

- Follow the project's existing conventions first. If the project profile below is missing, run the `flutter-project-profile` skill before building anything.
- If `.fvmrc` exists, run every Flutter and Dart command through FVM (`fvm flutter`, `fvm dart`).
- Never edit generated files (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `*.config.dart`). Run code generation instead.
- Ask before adding a package, and say which Android and iOS setup it needs.
- Write tests only when asked.
- Before a task, read the `Developer preferences` list below and follow it. When the developer states a standing preference ("from now on", "always", "never", "I prefer"), add it there as one short line and say you did. Do not store one-off instructions, secrets or personal data. The list is committed with the project, so the whole team shares it. A newer line overrides an older one; if a preference conflicts with a project rule, ask.
- Skills (in `.agents/skills/`): `flutter-project-profile`, `flutter-feature`, `flutter-feature-notes`, `flutter-review`, `flutter-new-project`, `flutter-estimate`, `flutter-service-setup` (consoles, keys, fingerprints, subscriptions), `flutter-release` (Fastlane, CI, Firebase, Play, TestFlight), `flutter-git`. Use the one that matches the task.
<!-- flutter-ai-kit:end -->
