# Store graphics: sizes and rules

Verified 2026-11-08 from the pages named in each section. Re-read them before a release; stores change these. Only phone, tablet and icon rows are covered in full. Watch, TV, car, Mac, Vision and XR rows are on the same pages.

## Google Play (https://support.google.com/googleplay/android-developer/answer/9866151)

| Asset | Rule |
|---|---|
| App icon | 32-bit PNG with alpha, 512 x 512 px, at most 1024 KB, must meet Google Play's icon design specifications |
| Feature graphic | JPEG or 24-bit PNG (no alpha), 1024 x 500 px |
| Screenshots, all device types | JPEG or 24-bit PNG (no alpha); each side 320 to 3840 px; the longer side at most twice the shorter; 8 per device type at most; at least 2 across device types to publish |
| Phone | General rules above. For promotional eligibility the page recommends at least 4 apps (3 games) at 1080 px minimum: 16:9 landscape from 1920 x 1080 or 9:16 portrait from 1080 x 1920 |
| 7-inch and 10-inch tablets, Chromebook | At least 4 screenshots, 1080 to 7680 px, 16:9 landscape or 9:16 portrait |
| Promo video | Optional for apps; YouTube URL, public or unlisted, ads off, not age-restricted, embeddable; only the first 30 seconds autoplay |

## App Store (https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications)

- 1 to 10 screenshots per device size; `.jpeg`, `.jpg` or `.png`; no alpha channel or transparency.
- You only supply the largest size per family; App Store Connect scales to smaller ones. Required: one iPhone set (the page lists iPhone "Dynamic Island (medium)" at 1179 x 2556 or 1206 x 2622 portrait as required, "Dynamic Island (large)" at 1260 x 2736, 1290 x 2796 or 1320 x 2868 as optional, and says "Face ID (large)" 1284 x 2778 or 1242 x 2688 is required only when no Dynamic Island (large) screenshots are given); iPad 13-inch (2064 x 2752 or 2048 x 2732 portrait) if the app runs on iPad. Landscape is the same pairs swapped.
- Older display sizes (Home Button and smaller iPads) are optional and scaled from the larger sets.
- The page was truncated in the Apple Watch section; check it directly if you ship a watch app.

## Review rules that affect images (https://developer.apple.com/app-store/review/guidelines/)

- 2.3.3: screenshots "should show the app in use, and not merely the title art, login page, or splash screen"; text and image overlays are allowed.
- 2.3.8: app name and icons (small, large, Watch, alternates) should be similar.
- 2.3.9: you must secure rights to all materials in icons, screenshots and previews and show fictional account information instead of real people's data.
- 4.1(c): no other developer's icon, brand or product name in your icon or name without approval.

## Not verified

- Whether the App Store 1024 x 1024 icon may have transparency: Apple's HIG says an imported background must be opaque and full-bleed; treat transparency as forbidden.
- Google Play's own icon design specification page (linked from the listing page) was not read; only the 512 x 512 size and format are confirmed.
