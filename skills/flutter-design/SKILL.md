---
name: flutter-design
description: Designs or aligns the look of a Flutter app. Builds screens from a provided design (Figma link, images, PDF) and lists every deviation, applies a design change, designs a new feature inside the existing look, or proposes a direction (colours, type, shape) and key screens when there is no design. Use ONLY when the developer asks for design work, provides a design to match, or asks for a redesign; never add design work to other tasks.
license: Apache-2.0
---

# Flutter design (on demand only)

Do not use this skill unless the request is about how the app looks: a design to match, a change to one, a new screen or feature that needs designing, or an app with no design yet. Other skills never start design work.

## Steps

1. **Pick the case** and open `references/design-cases.md` for its procedure:
   - **A. Design provided** (Figma link, screenshots, PDF, exported frames): build it and match it.
   - **B. Design changed:** compare old and new, update the theme first, then the screens.
   - **C. New feature, existing look:** design only what is missing, from the project's own tokens and components.
   - **D. No design at all:** agree a direction, then key screens, then build.
2. **Read the project first.** Find the theme layer (`ThemeData`, `ColorScheme`, `TextTheme`, `ThemeExtension`, or the project's own colour and style classes), the shared widgets, the string table and the project rules in `AGENTS.md`. Project rules win: if the project says "use `AppColors`", "use the generated `Assets` class" or a sizing package, follow that, not `references/theme-in-flutter.md`.
3. **Get the design source** with `references/design-sources.md` (Figma through its MCP server, images, what to do when a value cannot be read). Say which values were measured and which were estimated by eye.
4. **Put values in the theme, not in screens.** New colours, text styles, spacing and radii go to the theme layer first; screens only use them. Do not add a second theme system next to an existing one.
5. **Design every state, not only the happy path:** use `references/states-and-accessibility.md` (loading, empty, error, offline, long text, large text, dark theme, tap targets, labels).
6. **Check, then report.** Compare what you built with the design. If the app can be run (emulator, simulator or device, and the developer allows it), take screenshots and compare them side by side; if not, say the result was not visually checked. Finish with: screens built, deviations from the design (value, place, reason), assumptions, assets the developer must supply (fonts, icons, images, with their licence), and anything that needs a decision.

## Rules

- Never claim a pixel-accurate match you did not compare. "Matches the design" needs a comparison; otherwise say "built from the design, not compared".
- Do not copy another app's look, an existing brand's logo or a known character. Original work only. Record the licence of every font, icon set and illustration used.
- Do not add packages (fonts, icons, SVG, screen sizing) without asking; name the Android and iOS setup each one needs.
- Logo, launcher icon and store screenshots belong to `flutter-store-assets`. Flows and build plans are separate from this skill.
