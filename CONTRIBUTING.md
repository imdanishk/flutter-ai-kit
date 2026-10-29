# Contributing

Thanks for helping. The kit stays small on purpose: a skill is accepted only if it carries knowledge an agent would not guess (a project-specific procedure, a stack recipe, a checklist, a script). General Flutter advice does not belong here.

## Before you open a pull request

1. Keep `SKILL.md` under 500 lines; put detail in `references/` one level deep.
2. Write a `description` that says what the skill does and when to use it.
3. Do not add scripts that run on their own. Skills are instructions.
4. Run `dart tool/check.dart`, and `skills-ref validate skills/<name>` if you have it (`pip install skills-ref`).
5. Add a line under `## [Unreleased]` in `CHANGELOG.md`.
6. Say which agent and model you tried the change with, and what you saw. Nothing here is benchmarked, so real reports are the evidence.

## Versions

MAJOR.MINOR.PATCH. The version lives in `.claude-plugin/plugin.json` only. Patch: wording and fixes. Minor: new skill or reference, new installer option. Major: a change that makes existing installs behave differently (renamed skill, changed install paths).

## Releasing (maintainers)

1. Move the `Unreleased` notes under a new `## [x.y.z] - date` heading.
2. Set `version` in `.claude-plugin/plugin.json`.
3. `dart tool/check.dart`
4. Commit, then `git tag vX.Y.Z && git push --tags`. The release workflow builds the zip and publishes the GitHub release.

## Conduct

Be kind and specific. Disagree with ideas, not people.
