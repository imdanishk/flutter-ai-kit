# Store screenshots

## Capture

1. Real screens, real app, fictional data (Apple 2.3.9). Seed the app with realistic demo content, not placeholder text.
2. Capture at the largest required size per store from `store-graphics-specs.md`, or on a device or simulator whose native size matches. Do not stretch a smaller image; do not start emulators or simulators unless the developer asks.
3. Pick five to eight screens that tell the story in order: the main value first, then the next most important features, then trust (reviews, security, pricing if relevant). Apple 2.3.3: show the app in use, not title art, login or splash.
4. Keep order and names stable: Google Play shows screenshots in alphanumerical file-name order (Fastlane `supply` docs), so name files `01_...`, `02_...`.

## Marketing frames (optional)

- A headline above the screen plus a plain or branded background is allowed (Apple 2.3.3 allows text and image overlays). Keep the headline short, in the app's language, and readable at thumbnail size. Do not claim features the app does not have.
- Fastlane `frameit` adds device frames and titles with a `Framefile.json` and needs ImageMagick for text. Its frames come from a separate frame set, its docs do not say how current the newest iPhone frames are, and its docs say output without titles is full resolution and cannot be uploaded to the App Store directly: check the device list on the frameit page before relying on it. Source: https://docs.fastlane.tools/actions/frameit/.
- **ASO Shots** (`ceorkm/aso-shots`, MIT, last commit 2026-10-26) is an optional skill that writes the headlines, offers three of 18 styles, builds the set in HTML and exports PNGs. Its export presets match Apple's page (1206 x 2622 and 1320 x 2868 iPhone, 2064 x 2752 iPad) and Google's phone and tablet minimums. It generates artwork through an image API key or a Codex plugin and runs Node scripts. It was read, not run, and this kit does not install it: if the developer wants it, they read its scripts first and give its keys only to tools they trust.
- Other routes: a design tool the developer already uses, or an HTML page rendered at the exact pixel size. Pick what is installed; do not install tools without asking.
- Android and iOS may share artwork but not files: sizes and ratios differ.

## Folders for upload (verified from Fastlane docs 2026-11-08)

- **Google Play, `supply`:** `fastlane/metadata/android/<locale>/images/` with `icon`, `featureGraphic`, `promoGraphic`, `tvBanner` (PNG or JPG) and screenshot folders `phoneScreenshots/`, `sevenInchScreenshots/`, `tenInchScreenshots/`, `tvScreenshots/`, `wearScreenshots/`. Uploaded images replace the existing ones. A build must already have been uploaded manually once. Options: `skip_upload_images`, `skip_upload_screenshots`, `sync_image_upload`. Source: https://docs.fastlane.tools/actions/supply/.
- **App Store, `deliver`:** `fastlane/screenshots/<language>/` (for example `en-US`); `screenshots_path` points elsewhere. Deliver detects each screenshot's device type from its resolution. Options: `skip_screenshots`, `overwrite_screenshots` (clears earlier uploads first), `skip_metadata`. Source: https://docs.fastlane.tools/actions/deliver/.
- One set per language you list: the headline text must be in that language, and a language without its own screenshots shows the default language's (Play). Text limits per language and the App Store primary-language fallback are in `flutter-feature/references/localization-recipe.md` (if that skill is installed).
- Running these is a release action: use the `flutter-release` skill and ask first.

## Check before handing over

For every file: dimensions, format, alpha, size on disk, count per device type, and locale folder. On macOS `sips -g pixelWidth -g pixelHeight <file>` prints pixel size; elsewhere `file <image>` prints it for PNG and JPEG. Print what you measured next to the rule it must meet.
