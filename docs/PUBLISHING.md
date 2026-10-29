# Publishing checklist (for the maintainer)

1. Set the repository owner and author/owner display name in `README.md` and `.claude-plugin/*.json`. Optionally add your name or organisation to the copyright line at the end of `LICENSE`.
2. Create an empty public repository named `flutter-ai-kit` on GitHub (no README, no licence; they already exist here).
3. In this folder: `git init -b main`, `git add .`, `git commit -m "Initial release"`, then `git remote add origin ...` and `git push -u origin main`.
4. On GitHub: add the description, and topics `flutter`, `dart`, `ai-agents`, `agent-skills`, `claude-code`, `opencode`, `codex`, `cursor`. Turn on private vulnerability reporting (Settings, Security).
5. Check the `validate` workflow turns green on the first push.
6. Release: `git tag v0.1.0 && git push --tags`. The `release` workflow publishes the zip and notes.
7. Test each install route from a clean folder before announcing it.
