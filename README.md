# Flutter AI kit

Small, agent-agnostic instructions that help any AI coding agent build Flutter apps the way your project already does. It works with OpenCode, Claude Code, Codex, Cursor, Gemini CLI, Antigravity, VS Code Copilot, Grok Build and other tools that read the open [Agent Skills](https://agentskills.io) format or `AGENTS.md`.

Status: early (0.x), not benchmarked. Tried so far on two real apps and two fresh projects, all on the Cubit/Freezed stack; the Riverpod recipe is untested. The release lane templates were checked for Ruby syntax only (the version helper is unit-tested) and have not been run; the setup and release references were read from official pages in November 2026 and mark every line they could not confirm. Expect rough edges and please report them. The skills are short on purpose and contain only what an agent does not already know: how to read your project's conventions, complete feature recipes for two stacks (Cubit with Freezed, and Riverpod), a review checklist, an estimation method, store and console setup lists, a release runbook with Fastlane and CI templates, safe git rules, and an on-request testing skill.

## How it works

1. **Learn the project.** `flutter-project-profile` reads your `pubspec.yaml`, your folders and one complete feature, and writes a short profile (stack, example feature, commands, conflicts between docs and code) into `AGENTS.md`. It never edits rules you already have.
2. **Build the way the project builds.** `flutter-feature` reads the profile and your written rules, copies the shape of the example feature, runs code generation and the analyzer, and ends its summary with a **Rule conflicts** line.
3. **Review honestly.** `flutter-review` checks a diff against your written rules first, and reports a broken rule even when the code copies an existing pattern.

An illustrative summary line (invented names):

> Rule conflicts: `ItemsListCubit` calls `.fold()` although the rules say not to, because it adapts the repository's `Either` to the shared paging cubit, following `ContactsListCubit`; the page imports `ItemModel` from the data layer, contrary to the layer rule, because the existing repository contract returns that type.

## What it will not do

- It does not make an agent follow rules perfectly: these are instructions, and a model can still miss one. Read the "Rule conflicts" line and the review.
- It does not write or run tests unless you ask, and it does not start your app unless you ask.
- It does not replace your own rules. If your project has them, they win.
- Its feature notes are research: each entry says whether it is verified, and some are not.

## What you get

| Skill | Use it to |
|---|---|
| `flutter-project-profile` | Detect the stack and conventions and record a short profile in `AGENTS.md` |
| `flutter-feature` | Add or change a feature following the project's own patterns, then generate code and analyze |
| `flutter-feature-notes` | Look up how a feature is built in Flutter: package, backend needs, Android/iOS setup, custom work, store risks, with verified/unverified status |
| `flutter-review` | Read-only review of a diff with file and line findings |
| `flutter-new-project` | Create the base architecture (Cubit, Freezed, injectable, auto_route) with shared core types |
| `flutter-estimate` | AI-assisted effort ranges with approach class, backend dependency and Android/iOS differences |
| `flutter-service-setup` | The setup that must exist before a feature works, and what to hand the backend: per-environment Firebase projects, SHA fingerprints and signing keys, Maps and Places billing and keys, social login, push, subscriptions on Google Play and the App Store |
| `flutter-release` | Fastlane lanes with store-derived build numbers, iOS certificates and match, CI checklist, and the path from the command line to Firebase App Distribution, Google Play and TestFlight, plus store account, test track and review requirements |
| `flutter-testing` | Writes and runs tests following the project's own setup. Does nothing unless you ask for tests |
| `flutter-git` | Branch, commit and pull request conventions with safe defaults (no commit, push or force-push unless asked; never commit keys) |

The installer also writes a small managed block into `AGENTS.md` (about ten lines) with the always-on rules.

## Where each skill fits in the lifecycle

The kit uses skills, not a fixed chain of agents, because skills are the one format every agent tool reads. Any agent can pick up a phase.

| Phase | Skill |
|---|---|
| Plan and estimate | `flutter-estimate`, `flutter-feature-notes` |
| Set up accounts, consoles and keys | `flutter-service-setup` |
| Start a project | `flutter-new-project`, `flutter-project-profile` |
| Build | `flutter-feature` |
| Review | `flutter-review` |
| Test (on request) | `flutter-testing` |
| Version control | `flutter-git` |
| Ship and distribute | `flutter-release` |
| Maintain | the dated notes and references, refreshed as in `docs/REFRESH.md` |

Testing is on demand: `flutter-testing` does nothing unless you ask for tests, and no other skill adds tests.

## Install

Pick one. This repository is hosted at `imdanishk/flutter-ai-kit`.

**1. Skills only, any agent** (needs Node.js 22.20 or later). Uses the community [`skills`](https://github.com/vercel-labs/skills) installer. Run it in a normal terminal, in your project folder:

```
npx skills add imdanishk/flutter-ai-kit
```

It shows a list: choose the skills and agents, then confirm. If it is run where it cannot ask (inside an agent, a script, CI), it prints the prompt, installs nothing and still exits with code 0; add `--yes` to skip the questions:

```
npx skills add imdanishk/flutter-ai-kit --yes
```

(`--all` installs for every agent the tool knows, which is usually too many.) Check the result with `ls .agents/skills`.

**2. Claude Code plugin**

```
/plugin marketplace add imdanishk/flutter-ai-kit
/plugin install flutter-ai-kit@flutter-ai-kit
```

Plugin skills are prefixed, for example `/flutter-ai-kit:flutter-feature`.

**3. Full install with the `AGENTS.md` rules** (needs the Dart SDK, which comes with Flutter; with FVM use `fvm dart`). Download the zip from the [latest release](https://github.com/imdanishk/flutter-ai-kit/releases/latest) or clone the repository, then run:

```
dart tool/install.dart --target C:\path\to\your_flutter_app
```

- `--claude` also copies skills to `.claude/skills` and adds `@AGENTS.md` to `CLAUDE.md` (Claude Code reads `CLAUDE.md`, not `AGENTS.md`)
- `--copilot` also copies skills to `.github/skills` (VS Code Copilot)
- `--grok` also copies skills to `.grok/skills` (Grok Build reads `AGENTS.md` and `.grok/skills`)
- `--dry-run` shows what would change and writes nothing

Skills always go to `.agents/skills/`, which OpenCode, Codex, Cursor, Gemini CLI and Antigravity read. Running the installer again updates the kit's own skill folders and the managed block only; your other files and your project profile are left alone.

Then open the project in your agent and say: "Run the flutter-project-profile skill."

## Using it with other skill sets

The kit's skill names (`flutter-project-profile`, `flutter-feature`, `flutter-feature-notes`, `flutter-review`, `flutter-new-project`, `flutter-estimate`, `flutter-service-setup`, `flutter-release`, `flutter-git`, `flutter-testing`) did not collide with the official Flutter and Dart skill sets in a test project that had both installed. Those two official sets overlap each other (about 15 skills share names), so install them one at a time and check what remains. The profile skill checks whether the official Flutter and Dart skills are installed and, if not, tells you the install commands without installing anything (Flutter team: `npx skills add flutter/agent-plugins --skill '*' --agent universal --yes`; Dart team: `npx skills add dart-lang/skills --skill '*' --agent universal --yes`; Claude Code and other clients: https://docs.flutter.dev/ai/agent-skills).

## Updating

Install the new release over the old one (option 3), run `npx skills update` (option 1), or `/plugin marketplace update flutter-ai-kit` (option 2). Versions follow [Semantic Versioning](https://semver.org/); see [CHANGELOG.md](CHANGELOG.md).

## Remembering your preferences

Tell the agent a standing preference ("from now on use single quotes", "always put widgets in their own files") and it adds one line to the `Developer preferences` list in `AGENTS.md`. Every later task, in any agent tool, reads that list first. The list is committed with the project, so teammates share it; keep personal habits in your own agent's settings. Running the installer again never touches the list. This relies on the agent following the instruction: check that the line appears.

## Staying current

Packages, store rules and OS versions change. Each feature note carries a date, and the skills tell an agent to open the current package or policy page, look for a newer or better-maintained alternative, and say if it would recommend something different. The recipes also tell the agent to check current major versions first. A scheduled GitHub workflow opens a "Refresh feature notes" issue on the 1st and 15th of each month listing old or unverified entries (see `docs/REFRESH.md`).

## Feature notes

`flutter-feature-notes` holds research on how common app features are built in Flutter. Every entry ends with a dated status (verified, partly verified or unverified). Packages and store rules change quickly, so treat the notes as a starting point and let the agent re-check them. How to refresh them: `docs/REFRESH.md`.

## Choices

- Flutter versions are managed with FVM; the skills use `fvm` commands whenever `.fvmrc` exists.
- Testing is optional. No skill writes tests unless you ask.
- The default stack is Cubit, Freezed, injectable, auto_route, but `flutter-project-profile` and `flutter-feature` follow whatever the project already uses. See `docs/DECISIONS.md`.

## Check what you install

Skills are instructions your agent will follow. Read them (they are short) before using them on a work project. They contain no hooks or scripts that run on their own; the Fastlane and CI templates under `skills/flutter-release/assets/` run only when you copy them into a project and start them.

## Licence

Apache-2.0, see `LICENSE` and `NOTICE`. Contributions are welcome, see [CONTRIBUTING.md](CONTRIBUTING.md).
