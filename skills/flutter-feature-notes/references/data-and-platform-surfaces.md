# Architecture, data and networking (C) and platform surfaces beyond the app (J)

Shared assumptions: one mid/senior Flutter developer, design and backend APIs ready, QA and store review excluded, all day ranges are judgment estimates and not measured. Package versions and dates come from pub.dev pages opened on 2026-10-30; "published" dates are as shown on those pages. Where a page was not opened the entry says Verify.

Biggest decisions. Section C: pick one state/DI/routing stack once (Cubit + get_it + go_router is the default here) because the choice is a project-wide cost, not a per-feature one; use Dart 3 sealed classes and primary constructors where possible to shrink code generation; treat offline-first sync as a backend-and-product project, not a package install. Section J: almost every surface (widgets, Live Activities, Siri, watch, CarPlay, TV, Wallet) needs native Swift/Kotlin code and often a store entitlement; Flutter plugins only bridge data. Several plugins here are pre-1.0 or stale, and the entries say which.

Related first-pass docs: `01-data-sharing-and-linking.md`, `03-media-and-video.md`, `04-notifications-background-location.md`.

---

## C. Architecture, data and networking

### State management
<!-- meta: size=L; days=5-15; deps=flutter-only; platform-difference=none -->
- **Brief:** How UI state, async loading and business logic are held and tested. The choice shapes every screen, so decide before feature work starts.
- **Seen in:** Not user-visible. Used in virtually every production Flutter app.
- **Recommended approach:** flutter_bloc with Cubit by default and full Bloc (events) only where event traceability helps. Version 9.1.1, published 2025-05-02 by bloclibrary.dev (verified publisher), not discontinued, which is stable but not fast-moving. flutter_riverpod 3.4.3 (published 2026-09-03, dash-overflow.net) is an equally valid choice; rejecting it is a team-skills call, not a quality call. Provider-only is too thin for large apps.
- **Effort:** L, 5-15 days for the foundation (base cubit, loading/error states, observer, tests, conventions). Range driven by how many shared patterns (pagination, form state) are built up front.
- **Depends on:** Flutter-only.
- **Android/iOS differences:** None.
- **Custom work after the package:** State shape conventions (Freezed sealed states), error mapping, BlocObserver logging, test helpers (bloc_test), rules for what lives in a Cubit versus a widget.
- **Pitfalls and store review:** Giant "god" cubits; emitting after close; mixing two state libraries. None for store review.
- **What to tell the requester:** Not a feature the requester sees. Treat as project setup cost and agree one approach in writing.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/flutter_bloc and https://pub.dev/packages/flutter_riverpod.

### Routing and deep-link routing
<!-- meta: size=M; days=3-8; deps=flutter-only, backend; platform-difference=significant -->
- **Brief:** Declarative routes, auth redirects, nested tabs and mapping incoming URLs to screens.
- **Seen in:** Instagram and Uber open specific screens from web links; Airbnb listing links.
- **Recommended approach:** go_router 18.1.1 (published 2026-10-20, flutter.dev). The page states it is "feature-complete": bug fixes only, no new features, which is fine for routing. auto_route 11.2.0 (published 2026-09-21, codeness.ly) is the pick if the team wants generated typed routes and class-based guards (`AutoRouteGuard`), and it also has deep-link transformers.
- **Effort:** M, 3-8 days: route tree, guards, nested navigation, and deep-link tests. Range driven by number of shells (tabs) and link formats.
- **Depends on:** Flutter-only for the router; backend and hosting for link files.
- **Android/iOS differences:** Significant for link hosting: Android App Links need `assetlinks.json` and manifest intent filters; iOS Universal Links need `apple-app-site-association` and Associated Domains. See `01-data-sharing-and-linking.md`.
- **Custom work after the package:** Auth redirect rules, restoring state after login, unknown-link fallback, analytics on route change, link verification on both platforms.
- **Pitfalls and store review:** Link-file hosting errors are the top time sink; custom schemes are not verified links.
- **What to tell the requester:** Links open the right screen when the app is installed; "deferred" links after install need an extra service (Verify, see the linking doc).
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/go_router and https://pub.dev/packages/auto_route.

### Dependency injection
<!-- meta: size=M; days=1-4; deps=flutter-only; platform-difference=none -->
- **Brief:** Constructing and sharing services and repositories so they can be swapped in tests.
- **Seen in:** Not user-visible.
- **Recommended approach:** get_it 9.3.0 (published 2026-09-19, flutter-it.dev). Add injectable 3.0.0 (published 2026-04-20, codeness.ly) only if registrations grow beyond a few dozen; its generator adds build time and the README still shows an older build_runner command. Riverpod users do not need either.
- **Effort:** M, 1-4 days to set up modules, environments (dev/stage/prod) and test overrides.
- **Depends on:** Flutter-only.
- **Android/iOS differences:** None.
- **Custom work after the package:** Environment-specific registrations, scoping per user session (reset on logout), lifetime rules (singleton versus factory).
- **Pitfalls and store review:** Service-locator calls inside widgets hide dependencies; forgetting to reset user-scoped instances on logout leaks data between accounts.
- **What to tell the requester:** Internal plumbing only.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/get_it and https://pub.dev/packages/injectable.

### Code generation (immutable models, JSON)
<!-- meta: size=M; days=1-5; deps=flutter-only; platform-difference=none -->
- **Brief:** Generated equality, copyWith, unions and JSON parsing instead of hand-written boilerplate.
- **Seen in:** Not user-visible.
- **Recommended approach:** json_serializable 6.15.2 (published 2026-10-20, google.dev) for JSON, plus freezed 4.0.3 (published 2026-10-17, dash-overflow.net) where unions or copyWith are needed. The freezed page says Dart 3 sealed classes replace its `when`/`map`, and that primary constructors are stable from Dart 3.13, so freezed is now mainly for `==`, `toString` and copyWith. Prefer plain sealed classes for simple states. build_runner's version was not opened (Verify).
- **Effort:** M, 1-5 days to set up and convert; range driven by existing model count and freezed 2-to-4 migration.
- **Depends on:** Flutter-only.
- **Android/iOS differences:** None.
- **Custom work after the package:** CI step that runs the generator and checks for stale output; decide whether generated files are committed.
- **Pitfalls and store review:** Major-version jumps (freezed 3 migration guide exists); slow build_runner on big repos.
- **What to tell the requester:** Internal only. Cuts bugs, not visible features.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/freezed and https://pub.dev/packages/json_serializable; build_runner Verify.

### Clean architecture and repository pattern
<!-- meta: size=L; days=5-15; deps=flutter-only; platform-difference=none -->
- **Brief:** Layering (UI, logic, data) so features are testable and teams do not collide.
- **Seen in:** Not user-visible.
- **Recommended approach:** Flutter's official app-architecture guide: UI layer (views and view models), data layer (repositories wrapping services), optional domain layer. Add the domain/use-case layer only where logic is reused by several view models; a mandatory use-case class per call is overhead for most screens. Use a Result type for errors.
- **Effort:** L, 5-15 days for the template and one reference feature; ongoing cost per feature is small. Range driven by strictness.
- **Depends on:** Flutter-only.
- **Android/iOS differences:** None.
- **Custom work after the package:** No package; write the folder structure, base classes, lint rules, and a worked example feature. Sub-pages of the guide (concepts, recommendations, design patterns) were not opened, so details of its Result and command patterns are Verify.
- **Pitfalls and store review:** Over-layering small apps; DTO-to-model mapping boilerplate.
- **What to tell the requester:** Costs time up front, saves time on every later feature.
- **Status:** Partly verified: only the intro page https://docs.flutter.dev/app-architecture was opened; layer details are Verify.

### REST networking
<!-- meta: size=M; days=2-6; deps=flutter-only, backend; platform-difference=none -->
- **Brief:** HTTP client with auth headers, token refresh, cancellation and retries.
- **Seen in:** Every app with a server API.
- **Recommended approach:** dio 5.11.1 (published 2026-09-04, flutter.cn): interceptors, `QueuedInterceptor` (serialises token refresh) and one `CancelToken` cancelling many requests. The page does not mention retries; dio_smart_retry 7.0.1 was last published 2024-10-22 (stale; Verify), so write a short retry interceptor for idempotent requests. `http` 1.6.0 (dart.dev, about 11 months old) is fine for tiny apps but lacks these features.
- **Effort:** M, 2-6 days for client, refresh flow, error mapping, logging, tests.
- **Depends on:** Flutter-only; backend contract.
- **Android/iOS differences:** None (cleartext HTTP is blocked by default on both; Verify for your targets).
- **Custom work after the package:** Token refresh with single in-flight refresh, error-to-domain mapping, connectivity handling, certificate pinning if required.
- **Pitfalls and store review:** Parallel 401s causing refresh storms; retrying non-idempotent POSTs.
- **What to tell the requester:** Fully achievable; offline behaviour is a separate decision.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/dio, https://pub.dev/packages/http, https://pub.dev/packages/dio_smart_retry.

### GraphQL
<!-- meta: size=L; days=6-15; deps=flutter-only, backend; platform-difference=none -->
- **Brief:** Typed queries, mutations and live subscriptions against a GraphQL API with a normalised client cache.
- **Seen in:** GitHub and Shopify expose public GraphQL APIs used by their apps and partners.
- **Recommended approach:** ferry 0.16.1+2 for typed codegen and a normalised optimistic cache that fits stream-based Cubits. Risk: published 2025-01-06 (about 21 months), still pre-1.0, a dev prerelease exists. graphql_flutter 5.3.0 (published 2026-03-14, zino.company) is the lower-risk fallback: it needs a split HTTP/WebSocket link for subscriptions, and its default cache does not persist to disk (HiveStore needed).
- **Effort:** L, 6-15 days: schema download, codegen, links (auth, error), cache policies, subscriptions. Driven by schema size and cache complexity.
- **Depends on:** Backend (schema, subscriptions endpoint); Flutter-only otherwise.
- **Android/iOS differences:** None.
- **Custom work after the package:** Auth link and token refresh, cache key/type policies, pagination, mapping generated types to domain models, WebSocket reconnect.
- **Pitfalls and store review:** Codegen build time; schema drift between environments.
- **What to tell the requester:** Works well; ask whether the backend already supports subscriptions.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/ferry and https://pub.dev/packages/graphql_flutter.

### gRPC and WebSockets
<!-- meta: size=M; days=3-8; deps=flutter-only, backend; platform-difference=minor -->
- **Brief:** Long-lived streaming transports for chat, live prices, tracking.
- **Seen in:** Discord (WebSocket gateway), Slack, live-score apps.
- **Recommended approach:** web_socket_channel 3.0.3 (published 2025-04-17, tools.dart.dev) for WebSockets and grpc 5.2.0 (published 2026-10-15, dart.dev) for gRPC; grpc has grpc-web support. The web_socket_channel page does not mention reconnection, so build it yourself. Needing a protoc plugin for gRPC code is well known (Verify).
- **Effort:** M, 3-8 days: connection manager, backoff, heartbeat, auth, tests. Driven by protocol complexity.
- **Depends on:** Backend server (WebSocket or gRPC endpoint, load balancer support).
- **Android/iOS differences:** Minor: both platforms suspend sockets in the background (well known; Verify), so pair with push notifications; see `04-notifications-background-location.md`.
- **Custom work after the package:** Reconnect with backoff, resubscribe, message ordering, offline queue, app-lifecycle handling.
- **Pitfalls and store review:** Mobile networks and proxies drop idle sockets.
- **What to tell the requester:** Real-time works while the app is open; background delivery means push.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/grpc and https://pub.dev/packages/web_socket_channel.

### Offline-first and sync
<!-- meta: size=L; days=15-40; deps=flutter-only, backend, paid-service; platform-difference=none -->
- **Brief:** Local database as the source of truth, an outbox of pending writes, and conflict handling when back online.
- **Seen in:** WhatsApp (queued messages), Notion, Google Docs.
- **Recommended approach:** drift 2.35.3 (published 2026-10-23, simonbinder.eu; Android, iOS, desktop, web) with your own outbox, for modest scope. Choose powersync 2.5.0 (published 2026-10-19, powersync.com) when you need multi-device sync over Postgres, MongoDB, MySQL or SQL Server; it needs the PowerSync service, and hosting cost is Verify.
- **Effort:** L, 15-40 days. Driven by number of synced entities and conflict rules, which are product decisions.
- **Depends on:** Backend (idempotent writes, change feed or sync service); possibly a paid service.
- **Android/iOS differences:** None.
- **Custom work after the package:** Schema migrations, outbox with retry, conflict policy (last write wins or merge), delete tombstones, sync status UI, data wipe on logout.
- **Pitfalls and store review:** Conflicts and migrations are the real cost.
- **What to tell the requester:** Read caching is cheap; true offline editing with sync is a project. Ask which data must be editable offline.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/drift and https://pub.dev/packages/powersync; PowerSync pricing Verify.

### Background processing
<!-- meta: size=M; days=2-5; deps=flutter-only, native-android, native-ios; platform-difference=significant -->
- **Brief:** Periodic and deferred tasks (sync, uploads) when the app is not in front.
- **Seen in:** Photo-backup apps, mail clients, offline music downloads.
- **Recommended approach:** workmanager 0.10.10 (published 2026-09-07, fluttercommunity.dev), covered in `04-notifications-background-location.md`.
- **Effort:** M, 2-5 days; timing is not guaranteed.
- **Depends on:** Flutter-only plus native registration.
- **Android/iOS differences:** Significant: Android WorkManager versus iOS Background Tasks, with iOS deciding when to run (see the first-pass doc).
- **Custom work after the package:** Task entry points, retry policy, battery and network constraints, device testing.
- **Pitfalls and store review:** iOS may not run tasks at all; test on real devices.
- **What to tell the requester:** Best-effort only on iOS; no exact schedules.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/workmanager; details deferred to the first-pass doc.

### Monorepo and modules
<!-- meta: size=M; days=2-5; deps=flutter-only; platform-difference=none -->
- **Brief:** Several Dart/Flutter packages in one repository with shared dependencies.
- **Seen in:** Not user-visible; common in large Flutter teams.
- **Recommended approach:** Dart pub workspaces (Dart 3.6+) for resolution, and melos 8.9.0 (published 2026-09-21, invertase.io) for scripts and versioning. Melos 8 builds on workspaces and moved config from `melos.yaml` into the root `pubspec.yaml`. Workspaces alone suffice for small repos.
- **Effort:** M, 2-5 days to split a monolith; driven by coupling.
- **Depends on:** Flutter-only.
- **Android/iOS differences:** None.
- **Custom work after the package:** Package boundaries, CI that tests affected packages, release flow.
- **Pitfalls and store review:** One lockfile and one version per dependency across members; old melos 6/7 guides no longer match.
- **What to tell the requester:** Internal tooling.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/melos and https://dart.dev/tools/pub/workspaces.

### Native interop (platform channels, FFI, Pigeon)
<!-- meta: size=M; days=2-10; deps=flutter-only, native-android, native-ios; platform-difference=significant -->
- **Brief:** Calling Kotlin, Swift or C code from Dart.
- **Seen in:** Any app using camera, payments or SDK wrappers.
- **Recommended approach:** pigeon 29.0.11 (published 2026-10-20, flutter.dev): typed Kotlin/Swift/Dart code generation, with `@async` giving `suspend`/`async` signatures and event channels on Kotlin, Swift and Dart. For C libraries use dart:ffi through the `package_ffi` template (recommended since Flutter 3.38 per the docs). jnigen and Swift interop were not covered on the page (Verify).
- **Effort:** M, 2-10 days per bridge, driven by API surface and two-platform code.
- **Depends on:** Native Android and iOS code.
- **Android/iOS differences:** Significant: two separate native implementations; Pigeon's FFI/JNI interop is marked experimental.
- **Custom work after the package:** The native implementations, threading, error mapping, tests per platform.
- **Pitfalls and store review:** Apple library naming rules apply to native assets (identical names across SDKs).
- **What to tell the requester:** Anything native is reachable; each bridge is two small projects.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/pigeon and https://docs.flutter.dev/platform-integration/bind-native-code.

### Add-to-app
<!-- meta: size=L; days=10-30; deps=flutter-only, native-android, native-ios; platform-difference=significant -->
- **Brief:** Embed Flutter screens in an existing native app.
- **Seen in:** Native apps that embed Flutter for single screens or flows (Verify named examples).
- **Recommended approach:** Flutter's official add-to-app: Flutter module consumed by the native host; multi-engine mode on Android, iOS and macOS, multi-view on web.
- **Effort:** L, 10-30 days: module packaging, navigation handoff, data bridge, CI for both hosts. Driven by host build complexity.
- **Depends on:** Native host app code.
- **Android/iOS differences:** Significant: Gradle/AAR module versus CocoaPods or Swift Package Manager; Android supports AndroidX apps only.
- **Custom work after the package:** Shared auth and state bridge (Pigeon), engine pre-warming, navigation back-stack, versioning.
- **Pitfalls and store review:** Packing several Flutter libraries into one app is not supported; plugins assuming a Flutter activity may misbehave. FlutterEngineGroup and memory costs were not on the page (Verify).
- **What to tell the requester:** Feasible, but consider a full migration if the host is small.
- **Status:** Verified 2026-10-30 from https://docs.flutter.dev/add-to-app.

---

## J. Platform surfaces beyond the app

### Home-screen widgets
<!-- meta: size=L; days=8-20; deps=flutter-only, native-android, native-ios; platform-difference=significant -->
- **Brief:** Glanceable data on the home screen, updated by the app.
- **Seen in:** Weather apps, Spotify, Todoist, Google Calendar.
- **Recommended approach:** home_widget 0.10.0 (published about 42 days before 2026-10-30, antonborri.es). The page says widgets cannot be written in Flutter: the UI is native, with data shared from Dart; widgets can call Dart code and show Flutter-rendered images. Flutter docs suggest App Groups and workmanager for iOS refresh.
- **Effort:** L, 8-20 days: two native widget UIs plus data pipeline. Driven by variants and interactivity.
- **Depends on:** Native Android and iOS code.
- **Android/iOS differences:** Significant: iOS WidgetKit extension plus App Group; Android AppWidgetProvider or Glance (Glance not verified).
- **Custom work after the package:** SwiftUI and Android widget layouts, shared storage schema, refresh scheduling, deep links from taps.
- **Pitfalls and store review:** Widget refresh is rationed by the OS; extension memory is limited.
- **What to tell the requester:** Achievable but native design twice; refreshes are not real-time.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/home_widget and https://docs.flutter.dev/platform-integration/ios/app-extensions.

### Live Activities and Dynamic Island
<!-- meta: size=L; days=8-20; deps=native-ios, native-android, backend, store-approval; platform-difference=significant -->
- **Brief:** Real-time lock-screen and Dynamic Island cards for deliveries, rides and scores.
- **Seen in:** Uber, DoorDash, Apple Sports.
- **Recommended approach:** live_activities 2.6.0 (published 2026-09-11, dimitridessus.fr). iOS needs a Widget Extension, `NSSupportsLiveActivities`, an App Group, and an `ActivityAttributes` type named exactly `LiveActivitiesAppAttributes`. iOS 16.1+; Android support is beta and uses RemoteViews notifications (API 24+).
- **Effort:** L, 8-20 days, mostly SwiftUI layouts and the push pipeline.
- **Depends on:** Native code; backend sending APNs updates using the activity push token; Push Notifications capability.
- **Android/iOS differences:** Significant: native UI on both; Android is far less mature.
- **Custom work after the package:** SwiftUI lock-screen/Island views, backend token storage and update pushes, ending activities.
- **Pitfalls and store review:** Images limited to 4 KB; wrong attribute name means nothing appears.
- **What to tell the requester:** iOS is solid; Android only approximates it.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/live_activities.

### Siri, App Intents and Android AppFunctions
<!-- meta: size=L; days=10-25; deps=native-ios, native-android, third-party-sdk; platform-difference=significant -->
- **Brief:** Let Siri, Shortcuts and AI assistants run actions inside your app.
- **Seen in:** Apple Notes and Things (Shortcuts); Gemini integrations are early.
- **Recommended approach:** Write App Intents natively in Swift and pass data through an App Group or Pigeon. app_intents 0.18.0 (published 2026-10-02, unverified uploader, pre-1.0) covers iOS 17+ and Android API 36+; fine for a prototype, not yet a dependency to bet on. Android AppFunctions needs Android 16 and per Android docs is experimental, with Gemini integration in private preview as of May 2026, so skip it for production.
- **Effort:** L, 10-25 days; iOS only is lower.
- **Depends on:** Native code; Apple and Google platform features.
- **Android/iOS differences:** Significant: App Intents (Swift) versus AppFunctions (Kotlin annotations).
- **Custom work after the package:** Intent definitions, entity queries, how intents wake Flutter, App Group storage.
- **Pitfalls and store review:** Intents run in extension processes where data may appear reset without App Group storage.
- **What to tell the requester:** iOS Shortcuts and Siri are feasible; Android assistant actions are not production-ready.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/app_intents and https://developer.android.com/ai/appfunctions.

### Spotlight indexing and App Actions
<!-- meta: size=M; days=3-8; deps=native-ios, native-android; platform-difference=significant -->
- **Brief:** Make app content searchable from system search and assistants.
- **Seen in:** Apple Notes, Mail and Messages index content for system search.
- **Recommended approach:** flutter_core_spotlight 1.0.4 is iOS only and was last published 2021-07-05: treat as stale. Recommend a small Pigeon bridge to Core Spotlight (`CSSearchableIndex`) and Android shortcuts. App Actions details were not researched (Verify).
- **Effort:** M, 3-8 days.
- **Depends on:** Native code.
- **Android/iOS differences:** Significant: separate APIs, no shared package.
- **Custom work after the package:** Indexing triggers, deleting entries on logout, handling taps to deep link.
- **Pitfalls and store review:** Indexing personal data raises privacy duties; delete on sign-out.
- **What to tell the requester:** iOS Spotlight is straightforward; Android equivalents differ and need scoping.
- **Status:** Partly verified (flutter_core_spotlight page); App Actions Verify.

### Quick Settings tiles
<!-- meta: size=M; days=2-5; deps=native-android; platform-difference=significant -->
- **Brief:** A shade tile that triggers an action without opening the app.
- **Seen in:** VPN apps and Google's own utilities (Verify per app).
- **Recommended approach:** quick_settings 1.0.1 (published 2023-05-16, apparence.io): works without the app running, but it is about three years old. Prefer a small native `TileService` plus Dart callback for production; use the plugin for a prototype.
- **Effort:** M, 2-5 days.
- **Depends on:** Native Android only.
- **Android/iOS differences:** Android only; no iOS equivalent (Control Center widgets are a separate native feature; Verify).
- **Custom work after the package:** Tile states, icon assets, add-tile prompt.
- **Pitfalls and store review:** Programmatic add needs Android 13+; success flag unreliable per the page.
- **What to tell the requester:** Android only.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/quick_settings.

### Share targets and extensions
<!-- meta: size=M; days=3-8; deps=native-android, native-ios; platform-difference=significant -->
- **Brief:** Receive shared text, images and files from other apps.
- **Seen in:** WhatsApp, Instagram, Notion.
- **Recommended approach:** receive_sharing_intent 1.9.0 (published 2026-06-24, kasem.dev); details are in `01-data-sharing-and-linking.md`. iOS needs a Share Extension target plus App Group; Flutter docs warn extensions have limited memory (100 MB suggested minimum for UI).
- **Effort:** M, 3-8 days.
- **Depends on:** Native extension target (iOS), manifest intent filters (Android).
- **Android/iOS differences:** Significant.
- **Custom work after the package:** Extension UI, App Group handoff, content handling.
- **Pitfalls and store review:** Debug mode for extensions needs the simulator.
- **What to tell the requester:** Feasible on both; iOS is the larger part.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/receive_sharing_intent and https://docs.flutter.dev/platform-integration/ios/app-extensions.

### Apple Watch and Wear OS
<!-- meta: size=L; days=15-40; deps=native-ios, native-android, third-party-sdk; platform-difference=significant -->
- **Brief:** Companion watch apps for glanceable data, workouts, notifications.
- **Seen in:** Strava, Uber, Spotify.
- **Recommended approach:** Build the watch UI natively (SwiftUI for watchOS, Compose for Wear OS) and use Flutter only on the phone. voo_watch 0.5.4 (published 2026-05-26, voostack.com) and voo_wear 0.1.2 (published 2026-04-29) are very early: 1 like each, tens of downloads, and voo_wear says tiles and complications need native Compose. Flutter UI on watchOS is not available (Verify).
- **Effort:** L, 15-40 days per watch platform.
- **Depends on:** Native watch targets; entitlements.
- **Android/iOS differences:** Significant.
- **Custom work after the package:** Entire watch app, phone-to-watch messaging, data sync.
- **Pitfalls and store review:** Early packages can change; watch review is part of the phone app.
- **What to tell the requester:** Two native projects, not a port.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/voo_watch and https://pub.dev/packages/voo_wear.

### CarPlay and Android Auto
<!-- meta: size=L; days=10-25; deps=native-ios, native-android, store-approval; platform-difference=significant -->
- **Brief:** Template-based in-car screens for audio, navigation, parking or messaging.
- **Seen in:** Spotify, Google Maps, PlugShare.
- **Recommended approach:** flutter_carplay 1.7.1 (published 2026-10-06, oguzhanatalay.com) covers CarPlay and Android Auto templates (lists, grids, tabs, alerts and others); it lacks CarPlay map/navigation and contact templates.
- **Effort:** L, 10-25 days; entitlement lead time is not included.
- **Depends on:** Apple CarPlay entitlement per category; Android car app category approval (Verify).
- **Android/iOS differences:** Significant: different templates and entitlements.
- **Custom work after the package:** Template flows, state sync with the phone UI, audio session handling.
- **Pitfalls and store review:** Apple approval is needed for device use and distribution; simulator works before approval.
- **What to tell the requester:** Only certain app categories qualify; no free-form UI.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/flutter_carplay.

### Android TV, Fire TV and tvOS
<!-- meta: size=L; days=10-30; deps=flutter-only, native-android, native-ios, store-approval; platform-difference=significant -->
- **Brief:** Remote-first, focus-driven UI on TV.
- **Seen in:** Netflix, YouTube, Disney+.
- **Recommended approach:** Android TV and Fire TV: a normal Android build with TV manifest entries (Verify) and dpad 3.1.1 (published 2026-10-07, fluttercandies.com) for focus regions. dpad's 3.0 was a rewrite of 2.x and it has about 5k downloads. tvOS: flutter_tvos 1.1.3 (fluttertv.dev) is part of a separate open-source embedder project, not official Flutter, so treat as high risk.
- **Effort:** L, 10-30 days; tvOS higher.
- **Depends on:** Native manifest, store listings.
- **Android/iOS differences:** Significant.
- **Custom work after the package:** Focus design, remote keys, 10-foot layouts, TV-specific store assets.
- **Pitfalls and store review:** TV store quality rules (Verify).
- **What to tell the requester:** Android TV likely fine; Apple TV is experimental.
- **Status:** Partly verified: https://pub.dev/packages/dpad and https://pub.dev/packages/flutter_tvos; TV manifest and store rules Verify.

### Desktop, web and multi-window
<!-- meta: size=M; days=5-15; deps=flutter-only; platform-difference=minor -->
- **Brief:** Same codebase on Windows, macOS, Linux and web; several windows on desktop.
- **Seen in:** Not a single flagship; Flutter targets all three desktop OSes and web (see the desktop docs).
- **Recommended approach:** Built-in Flutter targets for Windows, macOS and Linux. Multi-window is experimental on the `main` channel behind `flutter config --enable-windowing` and subject to change per the Flutter blog; not for production yet.
- **Effort:** M, 5-15 days per target; driven by plugin availability and layout.
- **Depends on:** Flutter-only; per-platform plugins.
- **Android/iOS differences:** Not applicable (mobile plugins may lack desktop support).
- **Custom work after the package:** Responsive layouts, keyboard and mouse, window management, packaging and signing.
- **Pitfalls and store review:** Whether windowing reached stable is Verify.
- **What to tell the requester:** Desktop/web are real targets; multi-window should wait.
- **Status:** Verified 2026-10-30 from https://docs.flutter.dev/platform-integration/desktop and https://flutter.dev/blog/desktop-windowing-apis.

### Wallet passes
<!-- meta: size=M; days=4-10; deps=backend, native-ios, native-android, third-party-sdk; platform-difference=significant -->
- **Brief:** Add tickets, loyalty or boarding passes to Apple Wallet and Google Wallet.
- **Seen in:** Airline apps, Starbucks, Ticketmaster.
- **Recommended approach:** The backend must create and sign the pass. pass_flutter 2.0.2 (2023-08-09) only saves and reads passes; add_to_wallet 0.0.2 (2021-08-19) wraps the Apple Add button; both stale. add_to_google_wallet 0.0.5 (2024-08-28, Android, thedroidsonroids.com) is a button widget. Recommend a small native bridge to `PKAddPassesViewController` on iOS and the Google save link or that button on Android (Verify).
- **Effort:** M, 4-10 days; backend signing dominates.
- **Depends on:** Backend; Apple pass certificates and Google Wallet issuer account.
- **Android/iOS differences:** Significant.
- **Custom work after the package:** Pass design and signing service, update pushes.
- **Pitfalls and store review:** Certificate expiry; Google Wallet issuer approval (Verify).
- **What to tell the requester:** Feasible, mostly backend.
- **Status:** Partly verified from the four package pages above; Apple/Google Wallet requirements Verify.

### App Clips and Instant Apps
<!-- meta: size=L; days=8-20; deps=native-ios, native-android, store-approval; platform-difference=significant -->
- **Brief:** Tiny install-free entry points opened from links, QR codes or NFC.
- **Seen in:** Apple promotes App Clips for parking, scooter rental and food ordering (Verify per app).
- **Recommended approach:** Flutter docs describe an iOS App Clip target: deployment target 16.0 or higher, 15 MB uncompressed limit "larger apps may still exceed", a bundle-id Associated Domain, and extra Xcode build phases. No Flutter guide for Android Instant Apps was found (Verify).
- **Effort:** L, 8-20 days.
- **Depends on:** Native targets; associated domains; store configuration.
- **Android/iOS differences:** Significant.
- **Custom work after the package:** Xcode setup, size reduction, invocation URLs, handoff to the full app.
- **Pitfalls and store review:** `flutter attach` cannot auto-discover the session; use the debug URI.
- **What to tell the requester:** Check release-size feasibility first.
- **Status:** Partly verified from https://docs.flutter.dev/platform-integration/ios/ios-app-clip; Android Verify.

### Matter and smart home
<!-- meta: size=L; days=15-40; deps=native-ios, native-android, third-party-sdk; platform-difference=significant -->
- **Brief:** Commission and control Matter devices.
- **Seen in:** Google Home, Apple Home, SmartThings.
- **Recommended approach:** No mature Flutter package found. flutter_matter 0.0.11 (published 2026-09-08, unverified uploader, unknown license, 128 downloads) and google_matter_flutter 0.2.0 (Android only, relies on a Google demo SDK the README says not to use in production). Prefer the vendor's cloud API or native SDKs.
- **Effort:** L, 15-40 days.
- **Depends on:** Native SDKs; iOS Matter extension and App Groups.
- **Android/iOS differences:** Significant.
- **Custom work after the package:** Commissioning UX, ecosystem handling, device pairing codes.
- **Pitfalls and store review:** Early packages.
- **What to tell the requester:** High risk; confirm devices and ecosystems first.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/flutter_matter and https://pub.dev/packages/google_matter_flutter.

### Picture-in-Picture and split-screen
<!-- meta: size=M; days=3-8; deps=native-android, native-ios; platform-difference=significant -->
- **Brief:** Floating video and multi-window layouts.
- **Seen in:** YouTube, Netflix, Google Meet.
- **Recommended approach:** See `03-media-and-video.md` for PiP (pip_kit and native_picture_in_picture, both early versions). Split-screen is Android `resizeableActivity` plus adaptive layouts; iPad multitasking is a Verify.
- **Effort:** M, 3-8 days.
- **Depends on:** Native config on both platforms.
- **Android/iOS differences:** Significant: iOS PiP cannot show Flutter's video_player texture.
- **Custom work after the package:** Enter PiP from the video screen, resize layouts.
- **Pitfalls and store review:** Test on real devices.
- **What to tell the requester:** Android easy, iOS needs native video.
- **Status:** Partly verified from `03-media-and-video.md`; split-screen Verify.
