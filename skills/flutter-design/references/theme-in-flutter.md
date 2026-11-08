# Holding a design in Flutter

Follow the project's own theme layer if it has one. This is the default for projects that do not.

## Where values live

- **Colours:** a `ColorScheme` per brightness, passed to `ThemeData(colorScheme: ...)`. For roles that `ColorScheme` does not have (success, warning, brand accent, chart colours) use a `ThemeExtension`.
- **Text:** a `TextTheme` (or the project's text-style class), with the design's families, sizes, weights, line heights and letter spacing. Screens use `Theme.of(context).textTheme.<role>` and change only with `copyWith`.
- **Spacing, radii, sizes:** small `const` values in one file (for example a 4-based scale), referenced by name. A sizing package such as `flutter_screenutil` is a project choice: follow it if present, do not add it.
- **Component looks:** the component themes inside `ThemeData` (buttons, inputs, cards, dialogs, app bar) so every instance shares one style. Avoid styling each widget on its own.
- **One look or platform-adaptive:** ask which. The default is one Material look on both platforms; adaptive (Cupertino widgets on iOS) is a deliberate choice that doubles the review work. Do not mix the two by accident.
- **Dark theme:** a second `ColorScheme` and `ThemeData`, set with `MaterialApp.darkTheme` and `themeMode`. Design it, do not invert it: raised surfaces get lighter, accent colours may need a lighter tone for contrast.

## Facts (verified 2026-11-08 from Flutter's docs)

- Material 3 is the default since Flutter 3.16; `useMaterial3: false` opts out, and support for opting out will eventually be removed. Source: https://docs.flutter.dev/release/breaking-changes/material-3-default.
- `ColorScheme.fromSeed` generates a whole scheme from one colour, but "the seedColor may not wind up as one of the ColorScheme colors". Its optional per-role parameters replace generated colours, so use them (or build `ColorScheme` directly) when the design has exact brand colours. It also takes `brightness`, `dynamicSchemeVariant` (default `tonalSpot`, which is muted; `fidelity` stays closer to the seed) and `contrastLevel`. Source: https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html.
- `ThemeExtension` is the interface for adding custom properties (most often colours) to `ThemeData`; a subclass implements `copyWith` and `lerp`. Pass extensions to `ThemeData` or `copyWith` through `extensions`, and read one with the theme's `extension<T>()` method. Sources: https://api.flutter.dev/flutter/material/ThemeExtension-class.html and https://api.flutter.dev/flutter/material/ThemeData/extensions.html. (The exact `Theme.of(context).extension<T>()` call was not shown on those pages.)
- Text size follows the user's setting through `MediaQuery.textScalerOf(context)`, which returns a `TextScaler`. Do not fix text boxes to heights that clip scaled text.

## Fonts and icons

- Bundled font files work offline and need entries under `fonts:` in `pubspec.yaml`; the `google_fonts` package downloads at run time unless fonts are bundled. Either is a packaging choice: ask. Check each font's licence.
- Pick one icon family. Material icons ship with Flutter; others come from a package or exported SVG. Icons that carry meaning need a label (see the states file).
