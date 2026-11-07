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

- To compare, the agent needs a screenshot of the built screen. Options: `flutter screenshot` on a running device or emulator, or a screenshot the developer sends. Do not start emulators or builds unless asked.
- The Dart and Flutter team's MCP server (`dart mcp-server`) gives agents analyzer, test and runtime access; Flutter's docs page for it does not list screenshot tools, so do not promise them. Source: https://docs.flutter.dev/ai/mcp-server.

## Other design skills

- Skills built for the web (for example the Taste skill, whose current version targets company websites and needs Node and Chrome) do not fit a Flutter app. Flutter draws its own pixels, so HTML checkers see nothing useful.
- UI UX Pro Max (MIT) includes a Flutter guideline file and a style, colour and font recommender that runs Python scripts. It was read, not run, when this kit was written. If the developer already has it installed it may help in case D; this kit does not depend on it.
