# Feature index

One row per feature, with a short brief, the usual Flutter package, a size and how much the Android and iOS setup differ. This index is a list of leads, not a set of verified facts: package names come from research on 2026-10-23 and rows marked "(unverified)" were not confirmed from an opened source. Always check the package page for the current version, maintenance and platform support before recommending it.

Detailed, source-checked entries exist for these areas (search them by feature name):

- Sign-in, security and compliance (section B): `auth-security.md`
- Communication and social (section G): `communication-social.md`
- Commerce, delivery, booking and maps (section I): `commerce-maps.md`
- Architecture, data, networking and platform surfaces (sections C and J): `data-and-platform-surfaces.md`
- Guides with setup steps: `guides/` (data sharing and linking, payments, media and video, notifications, background work and location; dated 2026-10-14)

Size: small is under 2 days, medium is 2 to 10 days, large is over 10 days (one mid-level developer, design and backend ready). Android/iOS difference: none, minor, or significant (separate native configuration, an extension target, an entitlement or store review).

---

## A. Small utilities and device APIs

### A1. Text, input and content
| Feature | Brief | Flutter | Size | Android/iOS difference |
|---|---|---|---|---|
| Clipboard (plain) | Copy/paste strings, check contents | built-in `Clipboard` | small | minor (Android 13 copy toast, iOS paste prompt: unverified) |
| Rich clipboard | Images, HTML, files on clipboard | super_clipboard | medium | significant (Rust/NDK, content provider) |
| Rich text editor | WYSIWYG editing | flutter_quill, appflowy_editor, super_editor | medium to large | minor |
| Markdown rendering | Markdown to widgets | flutter_markdown_plus (flutter_markdown is discontinued) | small | none |
| HTML rendering | HTML to widgets | flutter_widget_from_html | small | minor |
| Input masks | Phone, card, date formatting | mask_text_input_formatter | small | none |
| OTP/PIN fields with SMS autofill | Code entry, paste, autofill | pinput (+ SmartAuth on Android) | small | significant for autofill |
| Autocomplete/typeahead | Suggestions while typing | built-in `Autocomplete`, flutter_typeahead | small | none |
| Autofill hints | Password/email autofill | built-in `AutofillGroup` (unverified) | small | minor (unverified) |
| Mentions and hashtags input | @user and #tag in text fields | flutter_mentions or custom (unverified) | medium | none |
| Phone number and country picker | Validation, formatting | intl_phone_field, libphonenumber (unverified) | small | none |
| Forms and validation | Field validation, multi-step forms | built-in `Form`, flutter_form_builder (unverified) | small | none |
| Keyboard handling | Avoid keyboard, visibility, input actions | built-in, keyboard_visibility (unverified) | small | minor |
| Signature pad | Capture a drawn signature | signature | small | none |
| Drawing/canvas | Custom painting, sketching | `CustomPaint` | medium | none |

### A2. Camera, media files and documents
| Feature | Brief | Flutter | Size | Android/iOS difference |
|---|---|---|---|---|
| Image/video picker | Gallery or camera pick | image_picker | small | minor (plist keys, Android Photo Picker) |
| Camera capture | Custom camera UI | camera | medium | significant (unverified) |
| File picker | Native file selection | file_picker | small | minor |
| Image crop | Native crop UI | image_cropper | small | minor (UCrop activity) |
| Image compress | Shrink before upload | flutter_image_compress | small | minor |
| Network image cache | Cached remote images | cached_network_image | small | none |
| Save to gallery | Write to camera roll | gal, saver_gallery (unverified) | small | significant (scoped storage, add-only key) |
| Image zoom/gallery/carousel | Pinch zoom, swipe gallery | photo_view, carousel_slider (unverified) | small | none |
| QR/barcode scan | Camera scan | mobile_scanner | medium | minor |
| QR generate | Render QR codes | qr_flutter | small | none |
| PDF view | Render PDF pages | pdfx, syncfusion_flutter_pdfviewer (licence applies) | medium | none |
| PDF generate/print | Build and print PDFs | pdf, printing | medium | minor |
| Document scanning | Edge detection and crop | cunning_document_scanner | medium | significant |
| OCR | Text recognition | google_mlkit_text_recognition | medium | significant (minSdk, iOS 15.5+, armv7) |
| Face detection / image labeling | ML Kit vision | google_mlkit_face_detection, google_mlkit_image_labeling | medium | significant |
| Downloads and open files | Download, open in external app | flutter_downloader, background_downloader, open_filex | medium to large | significant |
| File system | App directories | path_provider | small | none |
| Native drag and drop | Cross-app drag | super_drag_and_drop | medium | significant on Android |

### A3. Device, sensors and hardware
| Feature | Brief | Flutter | Size | Android/iOS difference |
|---|---|---|---|---|
| Permissions | Request/check runtime permissions | permission_handler | medium | significant (plist key per permission, Podfile macros) |
| Connectivity | Network type changes | connectivity_plus | small | none |
| Device and package info | Model, OS, app version | device_info_plus, package_info_plus | small | minor |
| Battery | Level, charging | battery_plus | small | none |
| Sensors | Accelerometer, gyro, barometer | sensors_plus | small | minor (NSMotionUsageDescription) |
| Shake detection | Trigger on shake | sensors_plus based (unverified) | small | none |
| Haptics and vibration | System haptics, custom patterns | built-in `HapticFeedback`, vibration | small | minor |
| Brightness, wakelock, orientation | Screen controls | screen_brightness, wakelock_plus, `SystemChrome` | small | minor |
| Screenshot/recording prevention | Block capture, app-switcher blur | no_screenshot | medium | significant |
| Speech-to-text | Dictation | speech_to_text | medium | significant |
| Text-to-speech | Read aloud | flutter_tts | small | minor |
| Contacts | Read/write address book | flutter_contacts | medium | significant |
| Calendar access | Device calendar events | device_calendar (stale) | medium | significant |
| NFC | Read/write tags | nfc_manager | medium | significant (iOS entitlement) |
| Bluetooth LE | Scan and connect devices | flutter_blue_plus (commercial licence applies) | large | significant |
| USB serial | Android serial devices | usb_serial | medium | Android only |
| Health data | HealthKit and Health Connect | health | medium | significant |
| Printing/POS hardware | Receipt printers, ESC/POS | printing, esc_pos packages (unverified) | medium | minor |

### A4. App shell and UI polish
| Feature | Brief | Flutter | Size | Android/iOS difference |
|---|---|---|---|---|
| Splash/launch screen | Native launch screen | flutter_native_splash | small | significant (Android 12 config) |
| App icons (adaptive, dark, tinted) | Launcher icons | flutter_launcher_icons | small | significant |
| Dynamic app icon | Change icon at runtime | flutter_dynamic_icon_plus | medium | significant |
| Home-screen shortcuts | Long-press quick actions | quick_actions | small | minor |
| Theming and dark mode | Light/dark, design tokens | `ThemeData` | small | none |
| Fonts and icons | Google Fonts, custom fonts | google_fonts | small | none |
| SVG, Lottie, Rive | Vector and animated assets | flutter_svg, lottie, rive | small to medium | none |
| Skeleton/shimmer loaders | Loading placeholders | skeletonizer | small | none |
| Pagination and pull-to-refresh | Infinite lists | infinite_scroll_pagination, `RefreshIndicator` | medium | none |
| Dialogs, sheets, toasts, pickers | Overlay UI | built-ins, toastification (unverified) | small | none |
| Charts and graphs | Data visualisation | fl_chart (unverified) | medium | none |
| Animations and gestures | Implicit/explicit, swipe, drag | built-in | medium | none |
| Context menus and text selection | Selection, copy menus | `SelectionArea` | small | minor |
| App lifecycle | Foreground/background hooks | `AppLifecycleListener` | small | none |

### A5. Storage, formatting and web content
| Feature | Brief | Flutter | Size | Android/iOS difference |
|---|---|---|---|---|
| Key-value storage | Simple settings | shared_preferences | small | none |
| Secure storage | Keychain/Keystore secrets | flutter_secure_storage | small | significant |
| Local databases | Object/relational stores | drift, sqflite, hive_ce, isar (stale stable), ObjectBox | medium to large | none (ObjectBox minor) |
| Localization (l10n/ARB), RTL | Translations, plurals, direction | intl, `flutter gen-l10n` | medium | none |
| Date, number, currency formatting; time zones | Locale-aware formatting | intl, flutter_timezone | small | none |
| URL, phone, SMS, email intents | Open external apps | url_launcher | small | minor (queries, LSApplicationQueriesSchemes) |
| WebView | Embedded web content | webview_flutter, flutter_inappwebview | medium | minor |
| Custom Tabs / SFSafariViewController | System in-app browser | flutter_custom_tabs | small | minor |
| In-app review | Native rating prompt | in_app_review | small | significant (behaviour) |
| App update prompts | Soft/force update | upgrader, in_app_update (Android) | small | significant |
| Logging and error handling | Logs, global error hooks | logger, talker, `FlutterError.onError` (unverified) | small | none |

---

## B. Authentication, security and compliance
| Feature | Brief | Flutter | Size | Android/iOS difference |
|---|---|---|---|---|
| Email/password and phone OTP | Core sign-in | firebase_auth, Auth0, Cognito, Supabase (unverified) | medium | significant |
| Social sign-in | Google, Apple, Facebook | google_sign_in, sign_in_with_apple, flutter_facebook_auth (unverified) | medium | significant (Apple sign-in is required on iOS when other social logins exist: unverified) |
| OAuth2/OIDC with PKCE | Browser-based sign-in | flutter_appauth (unverified) | medium | significant |
| Passkeys | Passwordless sign-in | passkeys (unverified) | medium | significant |
| Biometric auth | Face/fingerprint gate | local_auth | small | minor |
| Token refresh and sessions | Interceptors, queued refresh | dio | medium | none |
| MFA | Second factor | firebase_auth (unverified) | medium | minor |
| Secure PIN / app lock | In-app lock screen | local_auth + secure storage | medium | none |
| Integrity attestation | Block tampered clients | firebase_app_check (Play Integrity, App Attest) | medium | significant |
| Root/jailbreak/hook detection | Runtime protection | freerasp | medium | minor |
| Certificate pinning | Pin TLS certs | dio adapter, http_certificate_pinning (unverified) | medium | minor |
| Obfuscation | Rename symbols in release builds | `--obfuscate --split-debug-info` | small | none |
| Privacy manifest (iOS) | PrivacyInfo.xcprivacy, required-reason APIs | native config | small | iOS only |
| App Tracking Transparency | iOS tracking prompt | app_tracking_transparency | small | iOS only |
| Consent (GDPR/UMP) | Consent forms | google_mobile_ads UMP (unverified) | medium | minor |
| Play Data Safety and Apple privacy labels | Store disclosures | store consoles | small | significant |
| Account deletion and age gating | Store requirements | app + backend (unverified) | medium | significant |
| Kids/family compliance | COPPA, parental gates | (unverified) | medium | significant |

---

## C. Architecture, data and networking
| Feature | Brief | Flutter | Size | Android/iOS difference |
|---|---|---|---|---|
| State management | Cubit/BLoC, Riverpod, Provider | flutter_bloc, flutter_riverpod | large | none |
| Routing and deep-link routing | Declarative routes, redirects | go_router, auto_route | medium | significant for link hosting |
| Dependency injection | Service location, modules | get_it, injectable | medium | none |
| Code generation | Immutable models, JSON | freezed, json_serializable, build_runner | medium | none |
| Clean architecture, repository pattern | Layering, Result types, commands | Flutter app-architecture guide | large | none |
| REST networking | Interceptors, cancellation, retries | dio, http | medium | none |
| GraphQL | Queries, mutations, subscriptions | ferry, graphql_flutter | large | none |
| gRPC and WebSockets | Streaming transports | grpc, web_socket_channel | medium | none |
| Offline-first and sync | Local cache, outbox, conflict handling | drift, powersync (unverified) | large | none |
| Background processing | Periodic and deferred tasks | workmanager | medium | significant |
| Monorepo and modules | Multi-package repos | melos (pub workspaces) | medium | none |
| Native interop | Platform channels, FFI, Pigeon, plugin authoring | pigeon, `dart:ffi` | medium to large | significant |
| Add-to-app | Embed Flutter in a native app | Flutter add-to-app (unverified) | large | significant |

---

## D. Monetisation and payments
| Feature | Brief | Flutter | Size | Android/iOS difference |
|---|---|---|---|---|
| In-app purchases and subscriptions | Store billing | in_app_purchase, purchases_flutter (RevenueCat) | large | significant |
| Server-side receipt validation | Verify purchases | backend | medium | significant |
| Card payments | PaymentSheet, 3DS | flutter_stripe | medium | significant |
| Apple Pay and Google Pay | Native wallets | pay | medium | significant |
| Regional gateways | Razorpay, PayPal, UPI | razorpay_flutter etc. (unverified) | medium | significant (UPI mostly Android: unverified) |
| KYC and identity verification | Document and selfie checks | vendor SDKs (unverified) | large | significant |
| Open banking | Account linking | plaid_flutter (unverified) | medium | minor |
| Card scanning | Camera card entry | (unverified) | small | minor |
| Ads: AdMob formats | Banner, interstitial, rewarded, native, app-open | google_mobile_ads | large | significant (app ID, SKAdNetwork) |
| Ads: mediation | AppLovin, Unity, Meta adapters | gma_mediation_* (unverified) | medium | significant |
| Ads: policy and frequency | Placement rules, test devices | policy docs | small | none |
| Promo codes, coupons, referrals | Growth features | backend + Branch | medium | minor |

---

## E. Adaptive UI and accessibility
| Feature | Brief | Flutter | Size | Android/iOS difference |
|---|---|---|---|---|
| Adaptive and responsive layout | Breakpoints, window size classes | `LayoutBuilder`, `MediaQuery.sizeOf` | large | minor |
| Large screens and foldables | Tablets, display features | built-in (docs.flutter.dev/ui/adaptive-responsive) | medium | minor |
| Edge-to-edge and SafeArea | System bars, cutouts | built-in | small | significant on Android |
| Platform-adaptive widgets | Material vs Cupertino | `.adaptive` constructors | small | none |
| Text scaling and RTL | Large text, mirrored layouts | built-in, intl | medium | none |
| Accessibility | Screen readers, contrast, touch targets | `Semantics` | medium | minor (TalkBack vs VoiceOver) |
| Predictive back, input handling | Android back gesture, keyboard, mouse | built-in | small | Android only |

---

## F. Notifications, background and location
| Feature | Brief | Flutter | Size | Android/iOS difference |
|---|---|---|---|---|
| Push notifications | FCM, APNs | firebase_messaging, OneSignal (unverified) | medium | significant |
| Local notifications | Scheduled, channels | flutter_local_notifications | medium | significant |
| Rich/silent push, notification extensions | Images, data-only | native iOS extension (unverified) | medium | iOS only |
| Notification inbox | In-app message list | backend (unverified) | small to medium | none |
| Foreground services | Persistent notification tasks | flutter_foreground_task | medium | significant |
| Location and background tracking | Streams, always-on location | geolocator | medium | significant |
| Geofencing and battery-aware tracking | Region triggers | flutter_background_geolocation (licence) | large | minor |
| Maps | Markers, polylines, tiles | google_maps_flutter, flutter_map, Mapbox, Apple Maps (unverified) | medium | significant |
| Places, geocoding, directions, ETA | Address search and routes | Google/Mapbox APIs (unverified) | medium | none |

---

## G. Communication and social features
| Feature | Brief | Flutter | Size | Android/iOS difference |
|---|---|---|---|---|
| Chat with prebuilt UI | Channels, threads, reactions | stream_chat_flutter, Sendbird | large | minor |
| Chat UI with own backend | Message list and composer | flutter_chat_ui | medium | none |
| Chat transports | Socket.IO, GraphQL subscriptions, Firebase | socket_io_client, graphql_flutter | medium | none |
| Federated/E2EE chat | Matrix, Signal protocol | matrix, libsignal | large | minor |
| Typing, presence, read receipts, replies, reactions | Chat details | SDK or custom (unverified) | medium | none |
| Voice notes | Record and play | record, just_audio | small to medium | minor |
| Offline queue for chat | Outbox, retry | drift or SDK offline layer (unverified) | large | none |
| Voice/video calls | WebRTC and managed SDKs | flutter_webrtc, livekit_client, agora_rtc_engine, ZEGO | large | significant |
| Incoming-call UI | CallKit and full-screen intent | flutter_callkit_incoming | large | significant |
| Live streaming | Rooms, co-host | ZEGO, LiveKit, Agora | large | significant |
| Stories and ephemeral content | Expiring media | story_view (unverified) | medium | none |
| Reels/short-video feed | Preload and cache | video_player, cached_video_player_plus | large | minor |
| Feed, likes, comments, follows | Social graph UI | pagination + backend | large | none |
| Moderation, report, block | Safety tools | SDK or backend (unverified) | medium | none |
| Media upload with progress/resume | Background transfers | background_downloader | medium | significant |
| Video editing and filters | Trim, filters, export | pro_video_editor, ffmpeg_kit_flutter_new | large | none |
| AR effects and face filters | Camera effects | Banuba, DeepAR, Camera Kit (unverified) | large | (unverified) |
| Stickers and GIFs | Pickers | giphy_get (unverified) | small | none |
| Contact sync and find friends | Address-book matching | flutter_contacts | small | minor |
| Dating-style swipe cards | Card swiper | appinio_swiper | small | none |
| Referral and deferred deep links | Attribution links | flutter_branch_sdk (Firebase Dynamic Links shut down) | medium | significant |

---

## H. Media playback and streaming
| Feature | Brief | Flutter | Size | Android/iOS difference |
|---|---|---|---|---|
| Video playback | Basic player | video_player | medium | minor |
| HLS/DASH, DRM, subtitles, PiP | Streaming player | better_player_plus | large | significant (Widevine vs FairPlay) |
| Music/podcast playback | Playlists, gapless | just_audio, audio_session | medium | minor |
| Background audio and lock screen | Media controls | audio_service | large | significant |
| Casting | Chromecast, AirPlay | cast (AirPlay not covered: unverified) | medium | significant |
| Offline downloads for streaming | Encrypted downloads | native work (unverified) | large | significant |
| Picture-in-picture | Floating video | (unverified) | medium | significant |

---

## I. Commerce, delivery and booking
| Feature | Brief | Flutter | Size | Android/iOS difference |
|---|---|---|---|---|
| Catalog search with facets | Filters, ranking | algolia_helper_flutter, Typesense (unverified) | medium | none |
| Cart, wishlist, checkout | Core shopping flow | backend-driven (unverified) | large | none |
| Order tracking and live status | Status timeline, live map | maps + realtime | large | none |
| Reviews and ratings | UGC | backend (unverified) | medium | none |
| Food/grocery menus and modifiers | Option-heavy product pages | backend-driven (unverified) | medium | none |
| Ride-sharing driver tracking | Live location, ETA | maps + WebSocket/subscription | large | none |
| Booking and reservations | Slots, calendars | backend-driven (unverified) | medium | none |
| Fare/price estimates | Pricing UI | backend (unverified) | medium | none |
| Recommendations and personalisation | Feeds, carousels | backend (unverified) | medium | none |

---

## J. Platform surfaces beyond the app
| Feature | Brief | Flutter | Size | Android/iOS difference |
|---|---|---|---|---|
| Home-screen widgets | Data pushed to native widgets | home_widget | medium to large | significant (WidgetKit, Glance) |
| Live Activities and Dynamic Island | ActivityKit from Dart | live_activities | large | significant |
| Siri, App Intents, Android AppFunctions | Assistant actions | app_intents | large | significant |
| Spotlight indexing, App Actions | System search | (unverified) | medium | significant |
| Quick Settings tiles | Android shade tile | native TileService | medium | Android only |
| Share targets and extensions | Receive shared content | receive_sharing_intent | medium | significant |
| Apple Watch and Wear OS | Companion apps | voo_watch, voo_wear | large | significant |
| CarPlay and Android Auto | Car templates | flutter_carplay | large | significant |
| Android TV, Fire TV, tvOS | Remote-first UI | dpad, flutter_tvos | large | significant |
| Desktop, web, multi-window | Other targets | built-in, `--enable-windowing` (experimental) | medium | n/a |
| Wallet passes | Apple/Google Wallet | pass_flutter (stale), others (unverified) | medium | significant |
| App Clips and Instant Apps | Lightweight installs | native (unverified) | large | significant |
| Matter and smart home | Device commissioning | (unverified) | large | significant |
| PiP and split-screen | Window modes | (unverified) | medium | significant |

---

## K. Niche app families
| Family | Typical capability set | Flutter fit |
|---|---|---|
| Fintech/banking/wallet | Biometrics, secure PIN, KYC, card payments, NFC, pinning, root detection | friendly, moderate native work |
| Chinese-market and super-apps | WeChat login/pay/share (fluwx), Alipay (unverified), HMS push (huawei_push), no-GMS fallbacks, mini-program style web containers (unverified), vendor push (unverified), China store rules (unverified) | moderate to heavy |
| Education/e-learning | Video, quizzes, offline content, progress sync, live classes (unverified) | friendly |
| Healthcare/telemedicine | WebRTC, health data, secure messaging, compliance (unverified) | friendly, compliance heavy |
| Fitness/meditation | Health data, background audio, watch companion, foreground service | moderate native |
| Photo/video editing | FFmpeg, shaders, timeline UI, GPU filters (unverified) | heavy engineering |
| Drawing, whiteboard, notes | Canvas, rich text, sync (unverified) | friendly |
| Scanner and document apps | ML Kit, PDF, OCR | friendly |
| Games | Flame, game services (unverified), ads, IAP | friendly |
| AR/3D | ARKit, ARCore (stale), model_viewer_plus | heavy native |
| Logistics, fleet, field service | Background location, offline forms, signatures, barcode | moderate to heavy (iOS background rules) |
| Kiosk/POS/enterprise | Lock-task mode, MDM config, printers, USB | moderate native |
| Productivity, travel, real estate, news, podcast/audiobook | Calendars, maps, reader UI, background audio (unverified) | friendly |
| AI assistant apps | LLM chat UI, Firebase AI, on-device models (unverified), speech | friendly |
| Marketplaces | Listings, chat, payments, ratings (unverified) | friendly |

---

## L. Delivery, testing and operations
| Feature | Brief | Flutter | Size | Android/iOS difference |
|---|---|---|---|---|
| Analytics | Product events | firebase_analytics, mixpanel_flutter, posthog_flutter (unverified) | medium | minor |
| Attribution | Installs, deferred links | appsflyer_sdk, adjust_sdk (unverified), flutter_branch_sdk | medium | significant |
| Crash reporting | Crashlytics, Sentry | firebase_crashlytics, sentry_flutter | small to medium | minor |
| Remote config, flags, A/B | Change behaviour without a release | firebase_remote_config | small | none |
| Generative AI | Gemini via Firebase | firebase_ai | medium | none |
| On-device ML | TFLite, Gemma | tflite_flutter, flutter_gemma (unverified) | medium | minor |
| Flavors and environments | Dev/stage/prod | native flavors (unverified) | medium | significant |
| Signing and CI/CD | Keystore, provisioning, pipelines | Codemagic, Fastlane, GitHub Actions (unverified) | large | significant |
| OTA code push | Dart patches without store review | Shorebird | medium | minor |
| Testing | Unit, widget, integration, golden, native UI | flutter_test, patrol, mocktail, bloc_test (unverified) | medium | minor |
| Performance and app size | Profiling, jank, startup | DevTools, `--analyze-size` (unverified) | medium | none |
| Store review gotchas | Rejection causes | store guidelines | medium | significant |
| Platform version churn | UIScene (Flutter 3.38), SPM migration, Android 16 KB pages | release notes | medium | significant |

---

## Known gaps (not researched yet)
- Interactive/lock-screen widgets via Glance, Android 16 live updates
- Firebase Dynamic Links replacement guidance beyond Branch (own domain links)
- Android 15 and 16 KB page-size support, Play target-SDK policy, edge-to-edge enforcement
- Accessibility specifics per platform (Dynamic Type, TalkBack custom actions)
- Impeller shader jank and fragment shaders for filters
- Flutter on HarmonyOS/OpenHarmony (fluwx lists support)
- Alipay, UnionPay, Xiaomi/Oppo/vivo push, ICP filing
- Observability beyond crashes (logging pipelines, tracing)
