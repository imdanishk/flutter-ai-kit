# Getting the design into the agent

Checked 2026-11-08 unless marked.

## Figma

- Figma's official MCP server is hosted at `https://mcp.figma.com/mcp` (remote, recommended) and can also run through the Figma desktop app. Figma's docs list Claude Code, Claude Desktop, Cursor, VS Code, Codex, Copilot CLI, Kiro, Warp and OpenCode among the supported clients. Source: https://developers.figma.com/docs/figma-mcp-server/.
- It gives the agent design context (layout, variables, components) and can write to the canvas on the remote server. The desktop server needs a Dev or Full seat on a paid plan; writing outside drafts needs a Full seat. Whether the developer's plan allows it is their account's matter: ask, do not assume.
- The docs page does not mention Flutter, and its own FAQ suggests React output is common. Treat what it returns as a reference and rebuild it with the project's widgets and theme; never paste generated web markup.
- Ask the developer to share a frame link, not a whole file. Work screen by screen.

## Images, PDFs and exports

- Screenshots and exported frames can be read by an agent that sees images. Exact values (spacing, hex colours, font sizes) are not reliable from a picture: say "estimated" for them. Prefer a Figma link, a token export, or a style guide page when the design needs to be exact.
- If the design came with a style guide (colours, type, spacing), that is the source of tokens; the screens only confirm it.
- Large images: ask for one screen at a time.

## Seeing the running app

- To compare, the agent needs a screenshot of the built screen. Options: `flutter screenshot` on a running device or emulator (check `flutter screenshot --help` for the current flags), or a screenshot the developer sends. Do not start emulators or builds unless asked.
- The Dart and Flutter team's MCP server (`dart mcp-server`) gives agents analyzer, test and runtime access; Flutter's docs page for it does not list screenshot tools, so do not promise them. Source: https://docs.flutter.dev/ai/mcp-server.

## Inspiration libraries

- **Mobbin** (mobbin.com) is a library of 600,000+ shipped app screens, flows and animations. Its MCP server is on the Pro and Team plans only, its page says usage is unlimited during beta with limits to come, and it lists Claude Code, Cursor and Codex as clients (OpenCode is not mentioned). Its terms (checked 2026-11-08) forbid copying or mirroring the materials (3.2a, 3.2d), forbid bots and scrapers (3.2l) and automated tools used to make derivative works (3.3), and allow publishing screenshots elsewhere only to a limited extent with credit (10.3). So: use it to study patterns, only if the developer has a plan, and never copy a layout, save its screenshots into the repo or reproduce another app's design. This is not legal advice; the terms are the developer's to read.

## Other design skills (read, not installed, 2026-11-08)

Anyone installing a third-party skill should read its `SKILL.md` and bundled scripts first and check `allowed-tools`; Snyk's skill-security research (cited in https://snyk.io/articles/top-claude-skills-ui-ux-engineers/) reports prompt injection and credential-stealing code in a meaningful share of public skills. This kit installs none of the skills below.

| Skill | Licence | Verdict for Flutter |
|---|---|---|
| Taste skill | MIT | Web only: its current version targets company websites and needs Node and Chrome. |
| `ibelick/ui-skills` (8 skills) | MIT | Web only: Tailwind, React and ARIA rules. One idea kept: record the design language in one file so agents have persistent context, and audit against the project's own evidence rather than taste. |
| `ceorkm/mobile-app-ui-design` | MIT | Mobile principles (neutral/brand colour split, 4 or 8 point spacing, primary actions in thumb reach, empty states that guide), but its build notes are React, Tailwind and glass effects, and its industry file includes figures this kit did not verify. Generic patterns were restated in `states-and-accessibility.md`; nothing was copied. |
| `ceorkm/aso-shots` | MIT | Store screenshots: see `flutter-store-assets`. Optional. |
| UI UX Pro Max | MIT | Has a Flutter guideline file and a style/colour/font recommender in Python. Read, not run. May help in case D if the developer already has it. |
| AI UX Playground (aiuxplayground.com) | per skill | A catalogue of patterns and skills for designing AI products; nothing for mobile or Flutter. |

Skills built for the web check HTML; Flutter draws its own pixels, so those checks see nothing useful.
