# Communication and social features

Shared assumptions: one mid/senior Flutter developer, finished designs and backend APIs, excluding QA and store review. Almost every feature here is a backend and realtime problem first; the Flutter side is the smaller half. Biggest decisions: buy chat (Stream or Sendbird) unless you already own a realtime backend, in which case use flutter_chat_ui on top of it; use LiveKit as the default for calls and live rooms; treat incoming-call UI as native work with Apple rules attached; and plan moderation (report, block) from day one because both stores require it for user-generated content. Notification, background and location details live in `04-notifications-background-location.md`; video playback in `03-media-and-video.md`; payments for gifts in `02-payments-and-subscriptions.md`; link handling in `01-data-sharing-and-linking.md`.

## Messaging

### Chat with prebuilt UI (managed service)
<!-- meta: size=L; days=10-20; deps=flutter-only, backend, third-party-sdk, paid-service; platform-difference=minor -->
- **Brief:** Channels, threads, reactions and attachments from a hosted chat service with ready Flutter widgets. Apps buy it to skip building realtime infrastructure.
- **Seen in:** WhatsApp, Telegram, Slack, Discord (all custom-built; the managed route gets you close to the feel, not the scale).
- **Recommended approach:** stream_chat_flutter 10.6.0 (getstream.io verified publisher, published 2026-10-21): threads, quoted replies, reactions, typing and read indicators, voice messages, polls, offline storage via stream_chat_persistence. Sendbird is the alternative: sendbird_chat_sdk 4.10.4 (Android, iOS, web only) and sendbird_uikit 1.5.0, which supports group channels only and lists its licence as unknown.
- **Effort:** L, 10-20 days. Range driven by theming depth, custom message types and push setup.
- **Depends on:** Paid service (usage-priced, Verify current plans); backend to mint user tokens; push provider setup.
- **Android/iOS differences:** Minor. Photo and file pickers need the usual Android storage and iOS Info.plist entries (Stream's page defers to photo_manager, file_picker, image_picker guides).
- **Custom work after the package:** Theming, custom attachments, user directory and token endpoint, push token registration, deep links into channels.
- **Pitfalls and store review:** Vendor lock-in and per-user pricing; migrating history out later is hard. Reporting and blocking still need wiring (see moderation).
- **What to tell the requester:** WhatsApp-style chat is achievable quickly. Ask expected monthly active users, data residency needs and whether end-to-end encryption is required (managed services generally do not give it; Verify with the vendor).
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/stream_chat_flutter, https://pub.dev/packages/sendbird_chat_sdk, https://pub.dev/packages/sendbird_uikit. Pricing unverified.

### Chat UI on your own backend
<!-- meta: size=M; days=6-12; deps=flutter-only, backend; platform-difference=none -->
- **Brief:** A message list and composer widget you connect to your own API, without a vendor.
- **Seen in:** Support chat and in-app messaging in most marketplaces and booking apps.
- **Recommended approach:** flutter_chat_ui 2.12.0 with flutter_chat_core (flyer.chat verified publisher, Apache-2.0, published 2026-09-12; Android, iOS, web, desktop). Backend-agnostic, modular, themable. Rejected: building the list from scratch (reverse lists, scroll anchoring and image-heavy rows take days to get right).
- **Effort:** M, 6-12 days. Driven by message types (image, file, voice, reply) and pagination plus optimistic sending.
- **Depends on:** Your backend for history, send, delivery state, and a transport (see next entry).
- **Android/iOS differences:** None.
- **Custom work after the package:** Message model mapping, controller wiring, pagination, optimistic send and retry, attachment upload, date separators, unread divider.
- **Pitfalls and store review:** The 2.x line replaced the old 1.x API; old tutorials do not apply (Verify against the changelog before copying code).
- **What to tell the requester:** Good-looking chat is easy; the work is message state and delivery. Ask what the backend already supports.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/flutter_chat_ui. The 1.x versus 2.x change is Verify.

### Chat transports (Socket.IO, GraphQL subscriptions, Firebase)
<!-- meta: size=M; days=4-8; deps=flutter-only, backend; platform-difference=none -->
- **Brief:** The realtime connection that delivers messages: WebSocket-based events, GraphQL subscriptions or a managed database stream.
- **Seen in:** Any custom chat, live order tracking, collaborative apps.
- **Recommended approach:** Match your backend. Socket.IO server: socket_io_client 3.1.6 (unverified uploader, published 2026-06-13; version 3.x needs server 4.7 or later). GraphQL backend: graphql_flutter 5.3.0 (verified publisher, 2026-03-14) with a WebSocket link split from the HTTP link. Firebase: Verify (not opened). Pick the one your backend team already runs; do not add a second protocol.
- **Effort:** M, 4-8 days. Driven by reconnect handling, auth refresh and resubscribe after backgrounding.
- **Depends on:** Backend gateway, scaling (sticky sessions or a pub/sub adapter), push notifications as fallback when the socket is closed.
- **Android/iOS differences:** None for the socket. Sockets are suspended when the app is backgrounded on both; push is the wake-up path.
- **Custom work after the package:** Auth on connect, reconnect with last-seen cursor, deduplication by message ID, heartbeat, fallback to REST sync.
- **Pitfalls and store review:** Unreliable sockets on mobile networks; always sync missed messages on resume.
- **What to tell the requester:** Fully achievable. Ask which realtime stack the backend has and the expected concurrent users.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/socket_io_client, https://pub.dev/packages/graphql_flutter. Firebase option unverified (Verify).

### Federated and end-to-end encrypted chat
<!-- meta: size=L; days=20-40; deps=flutter-only, backend, third-party-sdk, native-android, native-ios; platform-difference=minor -->
- **Brief:** Chat where the server cannot read messages (Signal-style) or where users pick their own server (Matrix).
- **Seen in:** Signal, WhatsApp (encryption), Element, Threema.
- **Recommended approach:** The matrix SDK 14.2.0 (famedly.com verified publisher, published 2026-10-20) with flutter_vodozemac for encryption. It is AGPL-3.0; a closed-source app needs a legal review before use. Reject libsignal 9.0.0 for production: community bindings from an unverified uploader (4 likes), AGPL-3.0 binaries, and its own README says the app must make key stores durable and serialise per address or keys can be reused. It covers sessions and group sender keys, not registration or backup.
- **Effort:** L, 20-40 days. Driven by key backup, device verification and multi-device sync, which dominate.
- **Depends on:** Matrix homeserver (self-hosted or hosted) or your own key-distribution backend; security review.
- **Android/iOS differences:** Minor (native crypto libraries; libsignal needs Android SDK 24+, iOS 13+).
- **Custom work after the package:** Entire UI (the SDK has none), key backup and recovery UX, device verification, push gateway.
- **Pitfalls and store review:** Lost keys mean lost history. Encryption export compliance questions at store submission (Verify).
- **What to tell the requester:** WhatsApp-grade E2EE is not a package install. Matrix is the realistic route; custom Signal-protocol work needs a cryptography specialist.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/matrix, https://pub.dev/packages/libsignal.

### Typing, presence, read receipts, replies and reactions
<!-- meta: size=M; days=5-10; deps=flutter-only, backend; platform-difference=none -->
- **Brief:** The small signals that make chat feel alive: "typing...", online dot, delivered/read ticks, quoted replies, emoji reactions.
- **Seen in:** WhatsApp, Messenger, iMessage, Slack.
- **Recommended approach:** Use the managed SDK if you chose one; stream_chat_flutter lists typing and read indicators, quoted replies and reactions (verified on its page). On your own backend, build over the transport: typing as short-lived events (debounced, expiring in a few seconds), presence from heartbeat with a server-side expiry, read state as one "last read message" cursor per member, not one row per message.
- **Effort:** M, 5-10 days on your own backend; near zero with the SDK. Driven by group chats and privacy settings.
- **Depends on:** Backend events, storage for cursors and reactions.
- **Android/iOS differences:** None.
- **Custom work after the package:** Privacy toggles ("hide last seen"), group read counts, reaction pickers, reply jump-to-original.
- **Pitfalls and store review:** Presence leaks activity; offer a setting. Verify privacy-policy wording.
- **What to tell the requester:** Achievable with exact WhatsApp behaviour. Ask whether groups need per-member read lists.
- **Status:** Partly verified (feature list from https://pub.dev/packages/stream_chat_flutter); custom design is judgment.

### Voice notes
<!-- meta: size=M; days=3-6; deps=flutter-only, backend; platform-difference=minor -->
- **Brief:** Hold-to-record audio messages with waveform and playback.
- **Seen in:** WhatsApp, Telegram, Instagram DMs.
- **Recommended approach:** record 7.1.2 (cow-level.ovh verified publisher, 2026-10-09) to capture, just_audio 0.10.6 (ryanheise.com, 2026-06-29) to play, optionally audio_waveforms 2.0.2 (simform.com, 2026-01-09; Android and iOS only) for waveform drawing. Record as aacLc (m4a): record's page says Opus on iOS uses a CAF container that only plays on iOS.
- **Effort:** M, 3-6 days. Driven by hold-to-record gesture, lock mode and waveform upload.
- **Depends on:** Flutter-only plus backend file storage.
- **Android/iOS differences:** Minor. iOS needs `NSMicrophoneUsageDescription`; record requires Android SDK 23+ (Opus needs 29) and iOS 12+. Android RECORD_AUDIO manifest entry: Verify in the package README.
- **Custom work after the package:** Press-and-hold UI, slide to cancel, amplitude sampling for the waveform, upload, single-player-at-a-time logic, audio session handling when a call starts.
- **Pitfalls and store review:** Recording while backgrounded is not covered by the pages; Verify. Declare microphone use in privacy forms.
- **What to tell the requester:** Fully achievable. Ask maximum length and whether voice-to-text is wanted (separate service).
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/record, https://pub.dev/packages/just_audio, https://pub.dev/packages/audio_waveforms.

### Offline queue for chat
<!-- meta: size=L; days=8-15; deps=flutter-only, backend; platform-difference=none -->
- **Brief:** Send messages with no connection, show them immediately, retry in order, and show history offline.
- **Seen in:** WhatsApp, Telegram, Signal.
- **Recommended approach:** With a managed SDK, use its layer (Stream: stream_chat_persistence; offline storage and optimistic updates are listed on its page). On your own backend, drift 2.35.3 (simonbinder.eu verified publisher, 2026-10-23): reactive queries feed the UI, an outbox table holds pending sends. Reject ad-hoc key-value caches; ordering and migrations break them.
- **Effort:** L, 8-15 days. Driven by retry rules, attachment uploads in the queue and conflict handling.
- **Depends on:** Backend idempotency: a client-generated message ID so retries never duplicate.
- **Android/iOS differences:** None. Uploads that must finish in the background are covered in the media upload entry.
- **Custom work after the package:** Outbox state machine (pending, sent, failed), connectivity triggers, ordering by server timestamp, cleanup, schema migrations.
- **Pitfalls and store review:** Clock skew reorders messages; trust server time for ordering.
- **What to tell the requester:** Achievable and essential for chat quality. Ask how long history must stay offline.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/drift, https://pub.dev/packages/stream_chat_flutter.

## Calls and live rooms

### Voice and video calls
<!-- meta: size=L; days=12-25; deps=flutter-only, backend, third-party-sdk, paid-service, native-android, native-ios; platform-difference=significant -->
- **Brief:** One-to-one and group audio/video calls over WebRTC.
- **Seen in:** WhatsApp, FaceTime, Zoom, Google Meet.
- **Recommended approach:** livekit_client 2.13.2 (livekit.io verified publisher, Apache-2.0, 2026-10-26): rooms, screen share, end-to-end encryption on native, adaptive streaming; run LiveKit Cloud or self-host. Reject raw flutter_webrtc 1.6.3 (2026-10-26) unless you will run signalling and TURN yourself; its page does not cover either. Alternatives: agora_rtc_engine 6.6.4 (MIT, 2026-09-04) and zego_uikit_prebuilt_call 4.24.6 (2026-10-14, includes ready call UI), both vendor-priced.
- **Effort:** L, 12-25 days. Driven by group layouts, call state (ringing, busy, missed), reconnection and audio routing.
- **Depends on:** Backend that issues room tokens and rings the callee; LiveKit server or Cloud (paid or self-hosted); push for ringing.
- **Android/iOS differences:** Significant. Android: camera, microphone, Bluetooth and audio-settings permissions; screen share needs a media projection foreground service. iOS: camera and microphone Info.plist keys; `UIBackgroundModes` audio for background calls; min iOS 12.1; video publishing fails on the simulator.
- **Custom work after the package:** Call UI, ringing and signalling, device pickers, speaker and Bluetooth routing, network-quality indicator, call history.
- **Pitfalls and store review:** Test on real devices. Ringing when the app is closed is a separate feature (next entry).
- **What to tell the requester:** One-to-one calls are quick; large group calls cost server bandwidth. Ask maximum participants and whether recording is needed.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/livekit_client, https://pub.dev/packages/flutter_webrtc, https://pub.dev/packages/agora_rtc_engine, https://pub.dev/packages/zego_uikit_prebuilt_call, https://docs.livekit.io/transport/sdk-platforms/flutter/. Pricing unverified.

### Incoming-call UI (CallKit and full-screen intent)
<!-- meta: size=L; days=10-18; deps=flutter-only, backend, third-party-sdk, native-android, native-ios, store-approval; platform-difference=significant -->
- **Brief:** The native ringing screen that appears even when the app is closed or the phone is locked.
- **Seen in:** WhatsApp, Messenger, FaceTime, Viber.
- **Recommended approach:** flutter_callkit_incoming 3.1.6 (hiennv.com verified publisher, 2026-09-22; Android and iOS). Rejected: faking it with a normal notification, which does not ring over the lock screen on iOS.
- **Effort:** L, 10-18 days. Range driven by backend VoIP push plumbing and real-device testing of locked, killed and Do Not Disturb states.
- **Depends on:** Backend that sends an Apple VoIP push (PushKit) on iOS and a high-priority push on Android; native code in AppDelegate.
- **Android/iOS differences:** Significant. iOS: `voip` and `remote-notification` in `UIBackgroundModes`, PushKit registry in AppDelegate, token sent to the package; simulator does not fully support it. Android: `singleInstance` launch mode, ProGuard rule, notification permission (Android 13+), full-screen-intent permission (Android 14+).
- **Custom work after the package:** VoIP token upload, answer/decline handling that joins the call, missed-call and cancel pushes, audio session coordination.
- **Pitfalls and store review:** Apple's PushKit docs say apps linked against the iOS 13 SDK or later are terminated if a VoIP push is not reported to CallKit, and repeated failures stop VoIP launches; use VoIP push only for real calls. On Android 14 the full-screen-intent permission is intended for calling or alarm apps, and Play revokes it at install for others (source.android.com).
- **What to tell the requester:** WhatsApp-style ringing is achievable but only for genuine calling apps. Ask whether calls are a core feature (it decides store eligibility).
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/flutter_callkit_incoming, https://developer.apple.com/documentation/pushkit/pkpushtype/voip.md, https://source.android.com/docs/core/permissions/fsi-limits.

### Live streaming (rooms, co-host, gifts)
<!-- meta: size=L; days=15-30; deps=flutter-only, backend, third-party-sdk, paid-service, store-approval; platform-difference=significant -->
- **Brief:** One host broadcasts to many viewers with live chat, optional co-hosts and virtual gifts.
- **Seen in:** TikTok Live, Instagram Live, Twitch, Bigo Live.
- **Recommended approach:** LiveKit (livekit_client, see calls) for custom UI and low lock-in, so calls and live share one vendor. Pick zego_uikit_prebuilt_live_streaming 3.15.6 (zegocloud.com, 2026-01-23) only when you want host, co-host, audience, PK battles and gift UI prebuilt and accept vendor lock-in. Agora is the third option. Large audiences usually need broadcast-style delivery rather than one connection each; Verify vendor limits.
- **Effort:** L, 15-30 days. Range driven by co-host flows, gifts and wallet, and chat at scale.
- **Depends on:** Backend for rooms, tokens, chat and gifts; paid media service; store approval for virtual currency.
- **Android/iOS differences:** Significant: same camera, microphone and background rules as calls; ZEGO's prebuilt package targets Android and iOS only.
- **Custom work after the package:** Gift catalogue, wallet and top-up (in-app purchase rules in `02-payments-and-subscriptions.md`), viewer chat, moderation tools, recording.
- **Pitfalls and store review:** Live UGC needs report, block and takedown handling; virtual gifts bought with money on iOS normally must use in-app purchase (Verify guideline 3.1.1).
- **What to tell the requester:** A basic live room is achievable; a TikTok Live clone is a product with a wallet, moderation and payout system. Ask expected viewers per stream.
- **Status:** Partly verified (https://pub.dev/packages/zego_uikit_prebuilt_live_streaming, https://pub.dev/packages/livekit_client); scale and pricing unverified.

## Social content

### Stories and ephemeral content
<!-- meta: size=M; days=5-10; deps=flutter-only, backend; platform-difference=none -->
- **Brief:** Photos or short videos shown full screen in sequence that expire after a set time.
- **Seen in:** Instagram, WhatsApp Status, Snapchat, Facebook.
- **Recommended approach:** story_view 0.16.6 for the viewer (degreat.co.uk verified publisher; images, GIFs, video, pause and skip gestures; relies on flutter_cache_manager). Its last release is 2025-06-28, 15 months old, and it lists Android, iOS and macOS, so treat it as a fork candidate. Expiry is a backend rule (time-to-live), not a Flutter feature.
- **Effort:** M, 5-10 days including a creator flow. Range driven by editing tools and seen/unseen ring logic.
- **Depends on:** Backend for expiry, audience rules and viewer lists; media storage and CDN.
- **Android/iOS differences:** None.
- **Custom work after the package:** Story tray with seen state, composer (text, stickers, music), viewer list, replies, preloading the next story.
- **Pitfalls and store review:** Expiring content still needs reporting and moderation. Screenshots cannot be prevented reliably.
- **What to tell the requester:** The viewer is easy; the creator tools (text, filters, music) are where time goes.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/story_view.

### Reels and short-video feed
<!-- meta: size=L; days=10-20; deps=flutter-only, backend, third-party-sdk; platform-difference=minor -->
- **Brief:** Full-screen vertical videos, swipe to the next, instant playback with looping.
- **Seen in:** TikTok, Instagram Reels, YouTube Shorts.
- **Recommended approach:** video_player 2.14.1 (see `03-media-and-video.md`) in a vertical PageView with a small controller pool (current plus next one or two) and short MP4 renditions pre-cached with cached_video_player_plus 4.1.0 (outdatedguy.rocks, 2025-12-05). That package does not support HLS or DASH, so for adaptive streaming use video_player with prefetching you manage yourself. Verify package choice on devices.
- **Effort:** L, 10-20 days. Driven by preloading, memory release and low-end Android behaviour.
- **Depends on:** Backend transcoding and short-segment delivery; CDN.
- **Android/iOS differences:** Minor. ExoPlayer and AVPlayer differ in startup time and format support; test both.
- **Custom work after the package:** Controller pool, preload and dispose logic, cache limits, like/comment overlay, resume position, analytics.
- **Pitfalls and store review:** Memory pressure and decoder limits cause crashes on older phones; cap live controllers. Cache growth needs a size limit.
- **What to tell the requester:** The smoothness of TikTok comes from video encoding and preloading discipline, not a package. Ask target devices and clip length.
- **Status:** Partly verified (https://pub.dev/packages/cached_video_player_plus; the 03 file for video_player). Pool tuning is judgment.

### Feed, likes, comments and follows
<!-- meta: size=L; days=12-25; deps=flutter-only, backend; platform-difference=none -->
- **Brief:** Scrolling posts with reactions, comment threads and a follower graph.
- **Seen in:** Instagram, X, Facebook, LinkedIn.
- **Recommended approach:** infinite_scroll_pagination 5.1.1 (edsonbueno.com verified publisher, Flutter Favorite, 2025-08-28; PagingController API) for lists, with your existing state management. Release is 14 months old but the package is stable and widely used. Backend work (ranking, fan-out, notifications, counters) is the larger half.
- **Effort:** L, 12-25 days app side. Driven by comments (nested replies), optimistic like/follow and post composer.
- **Depends on:** Backend for the graph, feed ranking, counters and notifications.
- **Android/iOS differences:** None.
- **Custom work after the package:** Post cards, composer with media, optimistic like and follow, comment threads, profile screens, mentions and hashtags, deep links.
- **Pitfalls and store review:** User-generated content rules apply (moderation entry). Account deletion is required if you allow sign-up (App Store guideline 5.1.1(v)).
- **What to tell the requester:** The UI is routine; the algorithmic feed is a backend product. Ask whether the feed is chronological or ranked.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/infinite_scroll_pagination, https://developer.apple.com/app-store/review/guidelines/.

### Dating-style swipe cards
<!-- meta: size=S; days=1-3; deps=flutter-only, backend; platform-difference=none -->
- **Brief:** Stack of profile cards swiped left or right.
- **Seen in:** Tinder, Bumble, Hinge.
- **Recommended approach:** appinio_swiper 2.1.1 (appinio.app verified publisher; directions, undo, controller). Last release 2024-04-15, so keep it behind a thin wrapper in case you need to replace it.
- **Effort:** S, 1-3 days for the swiper; matching logic is backend.
- **Depends on:** Backend for candidates, matches and mutual-like detection.
- **Android/iOS differences:** None.
- **Custom work after the package:** Card design, like/nope overlays, paging of candidates, match screen, profile detail, undo (often a paid feature).
- **Pitfalls and store review:** Dating apps fall under user-generated content rules (report, block, contact details); age verification rules: Verify.
- **What to tell the requester:** The swipe is trivial; matching quality, safety and photo verification are the product.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/appinio_swiper.

## Safety, discovery and growth

### Moderation, report and block
<!-- meta: size=M; days=4-8; deps=flutter-only, backend, store-approval; platform-difference=none -->
- **Brief:** Let users report content, block people, and give your team tools to act.
- **Seen in:** Instagram, TikTok, Discord, Reddit.
- **Recommended approach:** Build the report and block UI yourself over your backend (reports table, block list applied in every query), or use the chat vendor's tools. Stream's Flutter SDK offers flagMessage, flagUser, muteUser, channel ban and shadow ban; application-level bans are server-side or in its dashboard, and its page documents mute, not block.
- **Effort:** M, 4-8 days. Driven by block semantics (hide in feeds, search, chat) and admin tooling.
- **Depends on:** Backend and a moderation queue or admin panel; optional paid auto-moderation.
- **Android/iOS differences:** None.
- **Custom work after the package:** Report reasons, block list enforcement everywhere, content filtering, admin queue, published contact details, terms acceptance.
- **Pitfalls and store review:** App Store guideline 1.2 requires filtering, a report mechanism with timely responses, blocking abusive users and published contact information. Google Play requires in-app reporting and blocking for public UGC and blocking for direct messaging, plus ongoing moderation.
- **What to tell the requester:** This is mandatory for social apps, not optional. Ask who reviews reports and the response time.
- **Status:** Verified 2026-10-30 from https://developer.apple.com/app-store/review/guidelines/, https://support.google.com/googleplay/android-developer/answer/9876937, https://getstream.io/chat/docs/sdk/flutter/guides/moderation/.

### Contact sync and find friends
<!-- meta: size=M; days=3-6; deps=flutter-only, backend; platform-difference=minor -->
- **Brief:** Read the address book, match phone numbers against registered users, suggest people to add.
- **Seen in:** WhatsApp, Telegram, Snapchat, Signal.
- **Recommended approach:** flutter_contacts 2.6.0 (quis.co verified publisher, 2026-10-03; Android, iOS, macOS; the author says it is maintained in free time). Normalise numbers to E.164 and send hashes to the backend for matching. Prefer the system picker when you only need one contact; Apple's guideline 5.1.1(iii) says to use out-of-process pickers where possible.
- **Effort:** M, 3-6 days (the inventory said S; permission flow, number normalisation and batching push it up).
- **Depends on:** Backend matching endpoint; privacy policy.
- **Android/iOS differences:** Minor. Android `READ_CONTACTS` (and `WRITE_CONTACTS` if editing); iOS `NSContactsUsageDescription`. iOS limited-contacts access handling: Verify.
- **Custom work after the package:** Pre-permission explanation screen, number normalisation, hashed upload, invite flow, handling denied permission, periodic re-sync.
- **Pitfalls and store review:** Uploading address books is sensitive; disclose it, minimise it, and note that plain hashed phone numbers are easy to reverse (Verify with a privacy reviewer).
- **What to tell the requester:** Achievable. Ask whether non-users can be invited by SMS and the region list for number formats.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/flutter_contacts, https://developer.apple.com/app-store/review/guidelines/.

### Referral and deferred deep links
<!-- meta: size=M; days=3-7; deps=flutter-only, backend, third-party-sdk, paid-service, native-android, native-ios; platform-difference=significant -->
- **Brief:** Invite links that survive the app-store install and open the right screen or credit the referrer on first launch.
- **Seen in:** Uber (invite codes), Airbnb, Dropbox, Duolingo.
- **Recommended approach:** flutter_branch_sdk 9.3.6 (rodrigomarques.dev verified publisher, 2026-10-15; Android, iOS, web). Firebase Dynamic Links shut down on 2025-08-25 and links now return 404, so do not use it. Google lists Adjust, Airbridge, AppsFlyer, Bitly, Branch, Kochava and Singular as parity options; App Links and Universal Links alone only cover installed apps (`01-data-sharing-and-linking.md`).
- **Effort:** M, 3-7 days. Driven by iOS and Android link configuration and attribution rules.
- **Depends on:** Branch (or similar) dashboard, third-party SDK; paid tiers for some features (QR codes need premium access; Verify plans); your referral rewards backend.
- **Android/iOS differences:** Significant. iOS: associated domains, Branch Info.plist keys, `FlutterDeepLinkingEnabled` set to false, optional `NSUserTrackingUsageDescription`; its iOS matching uses the pasteboard. Android: `flutter_deeplinking_enabled` meta-data false, install referrer timeout setting.
- **Custom work after the package:** Link generation, routing on cold start, referral code storage, reward grant on the backend, consent for attribution.
- **Pitfalls and store review:** Disabling Flutter's own deep-link handling conflicts with other link packages (see 01 file). Privacy forms and attribution consent apply.
- **What to tell the requester:** Referral installs can be attributed well on Android; iOS matching is best-effort. Ask whether a referral reward needs fraud controls.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/flutter_branch_sdk, https://firebase.google.com/support/dynamic-links-faq.

### Stickers and GIFs
<!-- meta: size=S; days=1-3; deps=flutter-only, backend, third-party-sdk; platform-difference=none -->
- **Brief:** Picker for GIFs, stickers and emoji in the chat composer.
- **Seen in:** WhatsApp, Instagram DMs, Messenger, Slack.
- **Recommended approach:** giphy_get 3.6.1+1 (unverified uploader, MIT, about 13 months old; GIFs, stickers, emoji tabs; Giphy API key needed). Fine for an MVP; for production prefer your own picker over the Giphy REST API through your backend, so the key stays private. Check the status of any other GIF API (Tenor) before choosing it: Verify.
- **Effort:** S, 1-3 days (own sticker packs need backend assets and take longer).
- **Depends on:** Giphy account and key; backend for custom sticker packs.
- **Android/iOS differences:** None.
- **Custom work after the package:** Send as a message type, caching, search history, attribution rules (Verify Giphy terms), custom sticker packs.
- **Pitfalls and store review:** Third-party GIFs can be inappropriate; apply content ratings and report options.
- **What to tell the requester:** Easy. Ask whether branded sticker packs are needed.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/giphy_get.

## Media creation tools

### Media upload with progress and resume
<!-- meta: size=M; days=4-8; deps=flutter-only, backend, native-android, native-ios; platform-difference=significant -->
- **Brief:** Upload large photos and videos reliably, with a progress bar, surviving app backgrounding and network loss.
- **Seen in:** Instagram, WhatsApp, Google Photos, TikTok.
- **Recommended approach:** background_downloader 9.6.4 (bbflight.com verified publisher, published about 17 days before the page was opened) for background transfers, uploading to presigned URLs issued by your backend. It lists multipart, binary and multi-file uploads with progress and notifications. Whether uploads can truly pause and resume is not stated on its page; for large videos use a resumable protocol (S3 multipart or tus) on the server: Verify.
- **Effort:** M, 4-8 days. Driven by chunking, retry rules and tying uploads to the chat or post outbox.
- **Depends on:** Backend presigned or resumable upload endpoints; object storage.
- **Android/iOS differences:** Significant. Android requires Kotlin 2.1.0+, min API 21; WorkManager limits standard tasks to 9 minutes, and user-initiated transfers on Android 14+ (priority 0) continue longer. iOS min 14.0; transfers must finish within the system timeout (default 4 hours). A user force-quit can end transfers on both.
- **Custom work after the package:** Compress before upload, queue and retry, notifications, linking upload status to the UI, cancel and delete.
- **Pitfalls and store review:** Do not promise uploads after force-quit. Notification permission matters on Android 13+.
- **What to tell the requester:** Reliable background upload is achievable within OS limits. Ask maximum file size and network conditions.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/background_downloader.

### Video editing and filters
<!-- meta: size=L; days=10-25; deps=flutter-only, native-android, native-ios; platform-difference=minor -->
- **Brief:** Trim, merge, crop, add overlays, filters and music, then export.
- **Seen in:** CapCut, TikTok, Instagram Reels, InShot.
- **Recommended approach:** pro_video_editor 2.43.2 (waio.ch verified publisher, BSD-3-Clause, 2026-10-23): trim, merge, crop, speed, audio, overlays, color matrices, progress and cancel, using Media3 on Android and AVFoundation on iOS. It ships no full editor UI (it points to pro_image_editor). Use ffmpeg_kit_flutter_new 4.6.7 (maintained fork of the retired FFmpegKit) only for gaps. Its default package includes GPL components, so choose a non-GPL variant (min, https, audio, video or full) to avoid GPL obligations for your app.
- **Effort:** L, 10-25 days. Driven by timeline UI, effect previews and export performance.
- **Depends on:** Native engines inside the package; no backend. Transcoding on a server is an alternative.
- **Android/iOS differences:** Minor. Cancellation works only on Android, iOS and macOS; some effects (blur) can look different from the preview; live effect previews need Impeller.
- **Custom work after the package:** The whole editor UI (timeline, trim handles, filter picker), preview sync, export presets, memory handling.
- **Pitfalls and store review:** GPL and codec licensing; large app size from FFmpeg; Verify patent and codec terms.
- **What to tell the requester:** Basic trim, filters and music are achievable; CapCut-level editing is a multi-month product.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/pro_video_editor, https://pub.dev/packages/ffmpeg_kit_flutter_new.

### AR effects and face filters
<!-- meta: size=L; days=10-20; deps=flutter-only, third-party-sdk, paid-service, native-android, native-ios; platform-difference=minor -->
- **Brief:** Real-time face tracking with masks, makeup, background replacement and lenses on the camera feed.
- **Seen in:** Snapchat, Instagram, TikTok effects.
- **Recommended approach:** banuba_sdk 3.1.6 (unverified uploader, published 2026-09-02; Android and iOS; face and hand tracking, makeup, virtual backgrounds, 14-day trial; client token required). It has few downloads (374), so pilot it first. Reject deepar_flutter 0.0.5 (deepar.ai publisher but last published 2023-01-29, stale); flutter_deepar 0.1.11 is a community wrapper from an unverified uploader. I found no Flutter plugin for Snap Camera Kit (search only; Verify).
- **Effort:** L, 10-20 days. Driven by effect authoring and camera integration.
- **Depends on:** Paid vendor licence; effects authored in the vendor's tooling (Verify).
- **Android/iOS differences:** Minor in the SDK setup (separate license keys per platform for DeepAR); min OS versions for Banuba: Verify.
- **Custom work after the package:** Effect selector UI, capture and record, effect asset delivery, performance tuning on low-end devices.
- **Pitfalls and store review:** Face data handling; Apple's rules say ARKit and camera data may not be used for marketing or data mining, and recording needs clear consent indication (guidelines 5.1.2 and 2.5.14).
- **What to tell the requester:** Filters from a vendor library are achievable; Snapchat's lens ecosystem is not.
- **Status:** Partly verified (https://pub.dev/packages/banuba_sdk, https://pub.dev/packages/deepar_flutter, https://pub.dev/packages/flutter_deepar); pricing and Camera Kit unverified.
