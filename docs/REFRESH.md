# Refreshing the feature notes

The notes in `skills/flutter-feature-notes/references/` go stale: packages are updated or abandoned, and store and OS rules change. Refresh them about every two weeks, and always before a release.

## Procedure

1. List entries to refresh, oldest first: `grep -rn "Status:" skills/flutter-feature-notes/references/*.md`. Start with `Unverified` and `Partly verified`, then anything with a date older than a month.
2. For each entry, open the sources it names (pub.dev package pages, official docs, store policy pages). Check: current version and publish date, maintenance (active, slow, stale, discontinued), platform support, licence, and any changed Android/iOS setup or store rule.
3. Edit the entry in place. Keep the field names. Update the `Status` line with the new date and the pages you actually opened. Mark what you could not confirm as `Verify`.
4. Do not copy facts from memory or search snippets into a `Verified` status. If a package is discontinued, change the recommended approach and say why.
5. Add new features to `references/index.md` and, when researched, to the matching area file.
6. Add a line to `CHANGELOG.md` under `Unreleased` (for example "Refreshed sign-in notes"). Releases that only refresh notes are patch versions.

## Pages that return no text

Some official pages are drawn by JavaScript, so a plain fetch returns only a title. A page that returns no article body counts as not opened.

- **Apple developer documentation:** fetch the JSON behind the page. For `https://developer.apple.com/documentation/<framework>/<symbol>` fetch `https://developer.apple.com/tutorials/data/documentation/<framework>/<symbol>.json` (lower case). This returns the real text. Check the result names the page you wanted.
- **Apple App Store Review Guidelines and support pages:** fetch the page directly; if it fails, search for the section text and open a result from developer.apple.com.
- **Other sites:** try the same page under a different path (for example the English docs root), or the project's repository README on GitHub. If nothing loads, leave the claim marked Verify; never fill it in from memory.

## Prompt for an agent (any model with web access)

> Refresh the entries in `skills/flutter-feature-notes/references/<file>.md` following `docs/REFRESH.md`. Open the source pages before changing any claim. Do not change field names. Report which entries changed, which could not be verified, and anything surprising.

## Wording rules

Write Android/iOS, verified/unverified, significant/minor. No abbreviations such as "A/iOS" or "sig".
