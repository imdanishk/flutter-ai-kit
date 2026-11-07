# Publishing checklist (for the maintainer)

One-time setup (done for this repository; repeat only for a fork): create the public GitHub repository, set the owner and author fields in `README.md` and `.claude-plugin/*.json`, add the description and topics (`flutter`, `dart`, `ai-agents`, `agent-skills`, `claude-code`, `opencode`, `codex`, `cursor`), and turn on private vulnerability reporting (Settings, Security).

Each release:

1. Change the skills, references or templates. Add a line under `## [Unreleased]` in `CHANGELOG.md`.
2. Bump `version` in `.claude-plugin/plugin.json` (the only place the version lives) and rename the changelog heading to `## [x.y.z] - date`.
3. Run `dart tool/check.dart` and `ruby tool/test_versioning.rb`; run `agentskills validate skills/<name>` for each skill you changed (`pip install skills-ref`).
4. Merge to `main`. The `validate` workflow must be green; the `release` workflow then creates the tag and the release zip by itself. Do not tag by hand.
5. Before announcing a new install route, test it from a clean folder.
