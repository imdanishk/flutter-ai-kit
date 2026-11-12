# App icon and launcher icons

Verified 2026-11-08 from the pages named below.

## Android adaptive icon (https://developer.android.com/develop/ui/views/launch/icon_design_adaptive)

- Foreground, background and monochrome layers are each 108 x 108 dp. The outer 18 dp on each side is reserved for masking and effects. The 66 x 66 dp centre is never clipped by a launcher mask: keep the logo inside it, at least 48 x 48 dp and no larger than 66 x 66 dp.
- Foreground and background are required for the full-colour icon; vectors are preferred, bitmaps allowed. The monochrome layer is optional: on Android 13 (API 33) and later the system tints it with the user's wallpaper colours; from Android 16 QPR 2 Android can theme icons that have no monochrome layer.
- Clean edges. No masks or shadows drawn into the layers. `android:roundIcon` is for launchers that use a circular mask.
- Resource XML lives in `res/mipmap-anydpi-v26/ic_launcher.xml` with `<background>`, `<foreground>` and `<monochrome>` drawables, referenced by `android:icon` in the manifest.
- The 512 x 512 Play Store icon is a separate file (see the specs table).

## iOS app icon (https://developer.apple.com/design/human-interface-guidelines/app-icons)

- 1024 x 1024 px square layout for iOS, iPadOS and macOS. Do not pre-round or pre-mask; the system applies the rounded-rectangle mask.
- Either one flat bitmap (PNG) or a layered Icon Composer file (Icon Composer comes with Xcode). A flat bitmap is split into two layers automatically; layered files give more control.
- Colour spaces: sRGB, Gray Gamma 2.2, Display P3 (wide gamut on iOS, iPadOS, macOS, tvOS, watchOS).
- Users can choose Default, Dark, Clear or Tinted appearances; you may supply variants, the system generates any you leave out. Keep the same core shapes in every variant; base the dark one on the light one.
- Avoid: text (unless essential to the brand; a single letter mark is fine), photos, screenshots or UI replicas, thin lines and sharp corners, custom shadows, bevels, blurs or glows, Apple hardware.
- An imported background must be full-bleed and opaque.

## Design approach

1. One idea, one shape, readable at 48 px. Test by shrinking the master to launcher size and looking at it.
2. Draw the master as SVG with a transparent safe area; export the foreground (no background) for Android and a full-bleed background-and-foreground square for iOS.
3. Palette from the project's theme or the brand; high contrast between the mark and its background; a monochrome version that still reads as one silhouette.
4. Check the icon beside the app name, on a light and a dark wallpaper.

## flutter_launcher_icons (https://github.com/fluttercommunity/flutter_launcher_icons)

If the project already uses another icon tool (a trial project used `icons_launcher` with a 1024 px master and a separate 512 px file for web), keep it, read its README for option names and do not add a second tool. Check its config in `pubspec.yaml` first. The notes below are for `flutter_launcher_icons` only.

Option names confirmed in its README: `image_path`; platform flags `android` and `ios` (true, false or a path); Android: `min_sdk_android`, `adaptive_icon_background`, `adaptive_icon_foreground`, `adaptive_icon_foreground_inset`, `adaptive_icon_monochrome`, `image_path_android`; iOS: `remove_alpha_ios`, `background_color_ios`, `image_path_ios`, `image_path_ios_dark_transparent`, `image_path_ios_tinted_grayscale`, `desaturate_tinted_to_grayscale_ios`. Flavors use one file per flavor named `flutter_launcher_icons-<flavor>.yaml` with the same format. The package is a dev dependency: ask before adding it. Run it with the project's `fvm` prefix when pinned. Its release cadence was not visible on the page; check pub.dev for the current version and date before adding.
