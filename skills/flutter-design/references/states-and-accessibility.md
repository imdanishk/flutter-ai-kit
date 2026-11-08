# States and accessibility

## States every screen needs

For each screen, decide and design: **loading** (first load and refresh), **empty** (with what to do next), **error** (what happened, what to do, a retry), **offline** or slow network when the feature uses the network, **partial data** (missing image, missing optional field), **long content** (long names, many items, 0 and 999+), **disabled and in-progress controls**, and **dialogs and sheets** with the same rules. Check the same list in dark theme and at a large text size.

Errors: say what happened in plain words, not a code; put the message where the user is looking (inline for a field, banner or snackbar for a failed action, full screen only when nothing can be shown); pair colour with an icon or text, never colour alone; keep the retry action next to the message.

## Accessibility (verified 2026-11-08)

- **Contrast:** Flutter's accessibility page encourages at least 4.5:1 between text or controls and the background, with disabled components excepted, and says images should be vetted for contrast too. Check pairs in both themes; do not trust the eye.
- **Tap targets:** Flutter's page says all tappable targets should be at least 48x48; `kMinInteractiveDimension` is 48.0. Apple's Human Interface Guidelines ask for a hit region of at least 44x44 pt for buttons. Use 48 as the single size for both platforms. The visual element may be smaller than its tap area.
- **Text scaling:** the UI should stay legible and usable at very large text sizes and display scaling (Flutter's page; no number given). Use flexible layouts, allow wrapping, test at the largest setting the platform offers.
- **Screen readers:** every control must be described intelligibly; test with TalkBack on Android and VoiceOver on iOS. Give icon-only buttons a tooltip or `Semantics` label, mark decorative images as excluded, and group related text into one reading.
- Sources: https://docs.flutter.dev/ui/accessibility, https://api.flutter.dev/flutter/material/kMinInteractiveDimension-constant.html, https://developer.apple.com/design/human-interface-guidelines/buttons.
- When the developer asks for tests, `flutter_test` has accessibility guidelines for tap target size, labels and text contrast (`androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline`, `textContrastGuideline`); the names are from `flutter_test` and were not re-checked against the API page. Do not add such tests unprompted.

## Motion and feedback

Keep animation short and purposeful; respect the platform's reduce-motion setting; give every tap visible feedback; never hide the only path to an action behind a gesture without an alternative.

## Mobile patterns worth checking (design judgement, not verified rules)

- Put the main action where a thumb reaches without stretching, usually the bottom of the screen; keep destructive actions away from it.
- Never show a blank search: offer recent searches or suggestions first.
- Prefer tappable choices (chips, lists, pickers) over typing for common options, with an "Other" field as the fallback.
- Use a timeline for statuses (orders, requests, uploads) instead of a list of dates.
- Make the empty state useful: say what belongs here and offer the next step.
- One font family (two at most), few sizes and weights; show hierarchy with size, weight and colour, not by making everything bold.

