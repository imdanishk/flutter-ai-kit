# Decisions

1. **Agent-agnostic.** Skills use the open Agent Skills format. `AGENTS.md` carries only a few always-on rules. Per-agent copies are optional (`--claude`, `--copilot`).
2. **Few skills.** A skill is added only if it carries knowledge an agent would not guess (project conventions, a stack recipe, a review checklist, an estimation method). Skills that restate general Flutter knowledge were left out.
3. **Project conventions win.** The profile is read from the project; the Cubit and Freezed recipe is a fallback for that stack.
4. **FVM** for Flutter version management. Commands use the `fvm` prefix when `.fvmrc` exists.
5. **Testing is optional** and never part of a default workflow.
6. **Own core types.** `Result`, `RequestStatus`, `FormInput`, `emitIfOpen` and paging helpers are small and dependency-free (except `flutter_bloc`), so there is no extra package. If you prefer `fpdart` or similar, say so during `flutter-new-project`.
7. **No benchmark claims.** Results depend on which agent and model you use. The kit does not claim a score.
8. **Licence:** Apache-2.0.

## Known gaps

- Recipes exist for Cubit with Freezed (injectable, auto_route) and for Riverpod 3. Plain BLoC, Provider and GetX projects work through the profile skill but have no recipe.
- No skills yet for accessibility, performance profiling, platform channels, or release and store submission.
- Feature notes cover four areas in detail; the rest of the feature index has briefs only. About a quarter of the detailed entries (20 of 79) are still partly verified or unverified.
