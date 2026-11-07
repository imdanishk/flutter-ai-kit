# Security

Skills are instructions that an AI agent will follow, so a malicious change could steer an agent. Report anything that looks like a prompt-injection risk, a command that touches files outside the project, or a script that runs without being asked, using GitHub's private vulnerability reporting for this repository.

The skills themselves are instructions and contain no hooks. The kit does ship templates that handle secrets and call external services when you copy them into a project and run them: Fastlane lanes (Firebase, Google Play, App Store Connect, match) and GitHub Actions workflows. Read them before use; they have not been run against a real project. The installer copies files into the folder you point it at, and replaces the kit's own skill folders there with the new version; use `--dry-run` to see what it will do.
