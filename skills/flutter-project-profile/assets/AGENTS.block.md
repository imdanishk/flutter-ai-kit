<!-- flutter-ai-kit:start v__VERSION__ -->
## Flutter working rules

- Follow the project's existing conventions first. If the project profile below is missing and the task is a new feature, a review or a new project, run `flutter-project-profile` first; for a small fix or a question, read the code involved and go on.
- If `.fvmrc` exists, run every Flutter and Dart command through FVM (`fvm flutter`, `fvm dart`).
- Never edit generated files (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `*.config.dart`). Run code generation instead.
- Before editing, read the code you will change and the closest existing example. If a request has more than one reasonable reading, or a missing detail that changes the result, ask; otherwise state your assumption in one line and go on.
- Make the smallest change that does the job: no unrequested features, no new abstraction for a single use, no refactoring or reformatting of code you were not asked to touch. Mention unrelated problems instead of fixing them, and remove only what your own change left unused.
- End by saying what you checked (analyzer, a run, a test) and what you did not; if you changed logic and wrote no test, say so.
- Ask before adding a package, and say which Android and iOS setup it needs.
- Write tests only when asked; then use `flutter-testing`.
- Never upload, publish, release or push unless asked to in this conversation.
- Before a task, read the `Developer preferences` list below and follow it. When the developer states a standing preference ("from now on", "always", "never", "I prefer"), add it there as one short line and say you did. Do not store one-off instructions, secrets or personal data. The list is committed with the project, so the whole team shares it. A newer line overrides an older one; if a preference conflicts with a project rule, ask.
- Skills are in `.agents/skills/`; pick one by its description. Used only when asked: `flutter-testing`, `flutter-design`, `flutter-store-assets`.
<!-- flutter-ai-kit:end -->
