# Flutter AI kit

Small, agent-agnostic instructions that help any AI coding agent build Flutter apps the way your project already does. It works with OpenCode, Claude Code, Codex, Cursor, Gemini CLI, Antigravity, VS Code Copilot, Grok Build and other tools that read the open [Agent Skills](https://agentskills.io) format or `AGENTS.md`.

Status: v0.1, not benchmarked. Early: expect rough edges and please report them. The skills are short on purpose and contain only what an agent does not already know: how to read your project's conventions, a complete feature recipe for one stack, a review checklist, and an estimation method.

## What you get

| Skill | Use it to |
|---|---|
| `flutter-project-profile` | Detect the stack and conventions and record a short profile in `AGENTS.md` |
| `flutter-feature` | Add or change a feature following the project's own patterns, then generate code and analyze |
| `flutter-review` | Read-only review of a diff with file and line findings |
| `flutter-new-project` | Create the base architecture (Cubit, Freezed, injectable, auto_route) with shared core types |
| `flutter-estimate` | AI-assisted effort ranges with approach class, backend dependency and Android/iOS differences |

The installer also writes a small managed block into `AGENTS.md` (about ten lines) with the always-on rules.

## Install

Pick one. This repository is hosted at `imdanishk/flutter-ai-kit`.

**1. Skills only, any agent** (needs Node.js 22.20 or later). Uses the community [`skills`](https://github.com/vercel-labs/skills) installer, which asks which agents to install for:

```
npx skills add imdanishk/flutter-ai-kit
```

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

## Updating

Install the new release over the old one (option 3), run `npx skills update` (option 1), or `/plugin marketplace update flutter-ai-kit` (option 2). Versions follow [Semantic Versioning](https://semver.org/); see [CHANGELOG.md](CHANGELOG.md).

## Choices

- Flutter versions are managed with FVM; the skills use `fvm` commands whenever `.fvmrc` exists.
- Testing is optional. No skill writes tests unless you ask.
- The default stack is Cubit, Freezed, injectable, auto_route, but `flutter-project-profile` and `flutter-feature` follow whatever the project already uses. See `docs/DECISIONS.md`.

## Check what you install

Skills are instructions your agent will follow. Read them (they are short) before using them on a work project. They contain no scripts that run on their own.

## Licence

Apache-2.0, see `LICENSE`. Contributions are welcome, see [CONTRIBUTING.md](CONTRIBUTING.md).
