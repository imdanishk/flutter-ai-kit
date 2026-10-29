<!-- flutter-ai-kit:start v__VERSION__ -->
## Flutter working rules

- Follow the project's existing conventions first. If the project profile below is missing, run the `flutter-project-profile` skill before building anything.
- If `.fvmrc` exists, run every Flutter and Dart command through FVM (`fvm flutter`, `fvm dart`).
- Never edit generated files (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `*.config.dart`). Run code generation instead.
- Ask before adding a package, and say which Android and iOS setup it needs.
- Write tests only when asked.
- Skills (in `.agents/skills/`): `flutter-project-profile`, `flutter-feature`, `flutter-review`, `flutter-new-project`, `flutter-estimate`. Use the one that matches the task.
<!-- flutter-ai-kit:end -->
