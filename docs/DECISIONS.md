# Decisions

1. **Agent-agnostic.** Skills use the open Agent Skills format. `AGENTS.md` carries only a few always-on rules. Per-agent copies are optional (`--claude`, `--copilot`).
2. **Few skills.** A skill is added only if it carries knowledge an agent would not guess (project conventions, a stack recipe, a review checklist, an estimation method). Skills that restate general Flutter knowledge were left out.
3. **Project conventions win.** The profile is read from the project; the Cubit and Freezed recipe is a fallback for that stack.
4. **FVM** for Flutter version management. Commands use the `fvm` prefix when `.fvmrc` exists.
5. **Testing is optional** and never part of a default workflow.
6. **Own core types.** `Result`, `RequestStatus`, `FormInput`, `emitIfOpen` and paging helpers are small and dependency-free (except `flutter_bloc`), so there is no extra package. If you prefer `fpdart` or similar, say so during `flutter-new-project`.
7. **No benchmark claims.** Results depend on which agent and model you use. The kit does not claim a score.
8. **Licence:** Apache-2.0.
9. **Lifecycle through skills, not agents.** Subagents differ by tool; skills work in all of them. Each phase is a skill any agent can run. A thin Claude-only subagent wrapper may come later.
10. **Setup and release knowledge is dated and labelled.** `flutter-service-setup` and `flutter-release` cite official pages with a verified date and mark every line not read on an official page as Unverified. Fastlane lanes are templates to adapt, not a tested pipeline.
11. **Testing is a skill that runs only on request.** `flutter-testing` exists so tests follow the project's setup when wanted; no other skill adds tests.
12. **Official skills are checked, not installed.** The profile skill reports whether the Flutter and Dart team skill sets are present and prints the install commands; the developer chooses, because the sets overlap and install many skills.
13. **Design and store assets are optional, on-request skills.** `flutter-design` and `flutter-store-assets` run only when the developer asks. Design values live in the project's Dart theme layer, not in a separate token file. Store sizes are copied from the stores' own pages with a date and source, and every unverified line is marked. Third-party design skills are not bundled: the Taste skill targets websites, UI UX Pro Max needs Python, and a design skill whose licence is unknown is not copied.
14. **Scripts only when a check is mechanical, and only in Dart.** Every Flutter developer has Dart; Node or Python runtimes would exclude some. Agent hooks are not used, because they differ per tool. No script ships untested.
15. **Plans and fixes are skills, not agents.** `flutter-plan` (flows as Mermaid text, ordered slices, blockers kept apart from effort) and `flutter-fix` (bug, refactor and upgrade as three modes that are never mixed in one change) run when the task matches. `flutter-plan` writes no file unless the developer agrees; `flutter-fix` does not upgrade during a bug fix. Commands in the upgrade checklist were read on the Dart, Flutter and FVM pages on 2026-11-08; native toolchain advice is marked unverified.

## Known gaps

- Recipes exist for Cubit with Freezed (injectable, auto_route) and for Riverpod 3. Plain BLoC, Provider and GetX projects work through the profile skill but have no recipe.
- Accessibility is covered only as a checklist inside `flutter-design`; Android and iOS native toolchain upgrades (Gradle, Kotlin, Xcode, pods) in `flutter-fix` are not verified against official pages; the plan and fix skills have not been tried on a real project; no skills yet for performance profiling or platform channels. No script yet checks store images against the size tables (the checks are done by hand with `sips` or `file`).
- Release lane templates and the two GitHub Actions workflows have only been syntax-checked (the version helper is tested); none has been run against a real project, so the Fastlane action names and parameters are unconfirmed. CI templates exist for GitHub Actions only. Sign in with Apple server details and Facebook login are second-hand and unverified.
- Feature notes cover four areas in detail; the rest of the feature index has briefs only. About a quarter of the detailed entries (20 of 79) are still partly verified or unverified.
