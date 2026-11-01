# Commerce, delivery, booking and maps

Shared assumptions: one mid/senior Flutter developer, finished designs and backend APIs, excluding QA and store review. Almost every commerce feature here is backend work with a Flutter front end, so the estimates cover the app side only. Biggest decisions: use google_maps_flutter as the default map (Mapbox only when you need custom styling or turn-by-turn navigation, flutter_map when you want no vendor key); never ship Directions or Routes keys inside the app, call routing from your backend; and treat live tracking as a backend and realtime problem first. Payment details live in `02-payments-and-subscriptions.md`; permissions and background location in `04-notifications-background-location.md`. Rate limits cut the research short, so several entries are only partly verified; each says which parts.

## Search, catalog and shopping flow

### Catalog search with facets
<!-- meta: size=M; days=4-8; deps=flutter-only, backend, third-party-sdk, paid-service; platform-difference=none -->
- **Brief:** Product search with filters (price, brand, size), sorting and typo tolerance. Apps need it because browsing alone does not scale past a few hundred items.
- **Seen in:** Amazon, Zalando, Etsy, Instacart.
- **Recommended approach:** A hosted search engine behind a ready Flutter helper: algolia_helper_flutter 1.6.0 (algolia.com, published 2025-12-17; filter state, facet lists, disjunctive faceting). Rejected: typesense 0.6.0 (README says "still under development", facets not confirmed on its page); if you self-host Typesense, call its REST API from the app instead. Database LIKE queries do not give facets or ranking.
- **Effort:** M, 4-8 days. Drives the range: number of facet types, infinite scroll, and index sync work on the backend (not counted).
- **Depends on:** Backend that pushes products to the index; paid service (Algolia is usage-priced, Verify current plans).
- **Android/iOS differences:** None.
- **Custom work after the package:** Filter UI (sheets, chips, range slider), result list with pagination, empty states, recent searches, analytics events, search-as-you-type debounce.
- **Pitfalls and store review:** Keep the search-only API key in the app, never the admin key. Verify index freshness for stock and price.
- **What to tell the requester:** Fully achievable. Ask for catalog size, filter list and whether a search vendor is already in use.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/algolia_helper_flutter and https://pub.dev/packages/typesense. Pricing unverified (Verify).

### Cart, wishlist and checkout
<!-- meta: size=L; days=10-20; deps=flutter-only, backend, third-party-sdk, paid-service; platform-difference=minor -->
- **Brief:** Cart with quantities and promo codes, saved items, address and delivery slot selection, payment, order confirmation.
- **Seen in:** Amazon, Shopify-based stores, Zalando, Instacart.
- **Recommended approach:** Server-owned cart (the backend calculates totals, tax, shipping and discounts) and a thin Flutter state layer; payment through flutter_stripe 14.2.0 (flutterstripe.io, published 2026-10-14; its page recommends PaymentSheet and supports Apple Pay and Google Pay) and, for wallet buttons, pay 3.3.0 (google.dev, 2025-11-21), as in `02-payments-and-subscriptions.md`. Rejected: client-side totals (tamperable) and the store billing API for physical goods.
- **Effort:** L, 10-20 days. Drives the range: guest carts and merging on login, address book, promo rules, payment edge cases, order idempotency.
- **Depends on:** Backend (mostly), paid payment processor, Apple Pay merchant setup and Google Pay Business Console.
- **Android/iOS differences:** Minor. iOS: Apple Pay merchant identifier and payment processing certificate; flutter_stripe needs iOS 13.0. Android: Google Pay Business Console account; flutter_stripe needs API level 21+, Kotlin 1.8.0+, an AppCompat-based activity theme and `FlutterFragmentActivity`.
- **Custom work after the package:** Cart persistence, optimistic updates, stock-conflict handling, retry-safe order submission, 3-D Secure return handling.
- **Pitfalls and store review:** Apple guideline 3.1.3(e) says apps selling physical goods or services consumed outside the app must use purchase methods other than in-app purchase, such as Apple Pay or card entry. Verify tax and invoice rules per country.
- **What to tell the requester:** Achievable at near parity with big retailers. Ask who calculates tax and shipping, which payment methods, and whether guest checkout is needed.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/flutter_stripe, https://pub.dev/packages/pay and https://developer.apple.com/app-store/review/guidelines/. Cart design is judgment; tax and invoice rules unverified (Verify).

### Reviews and ratings
<!-- meta: size=M; days=3-6; deps=flutter-only, backend; platform-difference=none -->
- **Brief:** Star ratings, written reviews with photos, helpful votes and moderation.
- **Seen in:** Amazon, Google Maps, Uber (driver rating), Airbnb.
- **Recommended approach:** Build the star input with built-in widgets; flutter_rating_bar 4.0.1 still works but was last published 2022-05-18, so I would not add a dependency for a 20-line widget. Photo upload via image_picker 1.2.4 (flutter.dev, published 2026-10-06; `pickMultiImage()` for several photos; iOS needs `NSPhotoLibraryUsageDescription` and `NSCameraUsageDescription`, Android needs no setup) and your storage backend.
- **Effort:** M, 3-6 days. Drives the range: photos, edit/delete, report flow.
- **Depends on:** Backend with moderation and abuse handling.
- **Android/iOS differences:** None.
- **Custom work after the package:** Rating summary bars, sorting and filtering, accessibility labels (Semantics) for stars, profanity or spam report flow.
- **Pitfalls and store review:** Apple guideline 1.2 requires apps with user-generated content to have a method for filtering objectionable material, a mechanism to report offensive content with timely responses, the ability to block abusive users, and published contact information.
- **What to tell the requester:** Easy on the app side; moderation policy and fake-review prevention are the real work.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/flutter_rating_bar, https://pub.dev/packages/image_picker, https://developer.apple.com/app-store/review/guidelines/ and https://docs.flutter.dev/ui/accessibility/assistive-technologies (which only confirms that `Semantics` customises the accessibility tree). Google Play user-generated content rules unverified (Verify).

### Food and grocery menus with modifiers
<!-- meta: size=M; days=5-10; deps=flutter-only, backend; platform-difference=none -->
- **Brief:** Product pages with required and optional choices (size, toppings, substitutions), min/max rules and live price.
- **Seen in:** Uber Eats, DoorDash, Instacart.
- **Recommended approach:** Data-driven forms: the backend sends option groups with rules and prices, Flutter renders them generically and validates locally; the server recomputes the price. No package needed: Flutter's own `Form` with a `GlobalKey<FormState>` and field `validator` functions (docs.flutter.dev form validation recipe) covers required choices and min/max counts, and `autovalidateMode` can show errors as the user taps. Judgment: option-group widgets are custom code.
- **Effort:** M, 5-10 days. Drives the range: nested modifiers, availability by time, substitutions.
- **Depends on:** Backend schema for option groups.
- **Android/iOS differences:** None.
- **Custom work after the package:** Option-group widgets, validation, sticky price bar, cart line equality (same item, different options), reorder.
- **Pitfalls and store review:** Cart line merging bugs are the usual defect (judgment). Allergens: the European Commission page says Regulation (EU) 1169/2011 makes allergen information mandatory for non-prepacked food, including restaurants and cafes, with the same labelling requirements for online and distance selling. Rules for other countries are unverified (Verify).
- **What to tell the requester:** Achievable, and the schema matters more than the UI. Ask for the most complex menu item you must support and which countries you sell in.
- **Status:** Partly verified 2026-10-31 from https://docs.flutter.dev/cookbook/forms/validation (page says it reflects Flutter 3.47, updated 2026-10-06) and the European Commission food information legislation page. Menu design is judgment; allergen rules outside the European Union unverified (Verify).

### Booking and reservations
<!-- meta: size=M; days=5-10; deps=flutter-only, backend; platform-difference=none -->
- **Brief:** Pick a date and time slot, party size or service, then confirm, change or cancel.
- **Seen in:** OpenTable, Airbnb, Booking.com, Calendly-style apps.
- **Recommended approach:** table_calendar 3.3.0 for the date picker (events via `eventLoader`, range selection; page shows a release 28 days before capture; listed as an unverified uploader, so review the code before adopting). Slots come from the backend with a short hold. Rejected: computing availability on the client.
- **Effort:** M, 5-10 days. Drives the range: time zones, recurring rules, hold and expiry, rescheduling.
- **Depends on:** Backend availability and double-booking prevention; payment per `02-payments-and-subscriptions.md` if a deposit is taken.
- **Android/iOS differences:** None.
- **Custom work after the package:** Slot grid, time zone display, countdown for held slots, add-to-calendar and reminders (see 04 for local notifications).
- **Pitfalls and store review:** Show times in the venue's time zone. Verify cancellation-fee wording with the store rules for services.
- **What to tell the requester:** Easy front end; the hard part is the availability engine. Ask about overbooking policy and time zones.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/table_calendar. Rest is judgment.

### Fare and price estimates
<!-- meta: size=M; days=3-7; deps=flutter-only, backend, third-party-sdk, paid-service; platform-difference=none -->
- **Brief:** Show an upfront price or range for a trip, delivery or service before the user confirms.
- **Seen in:** Uber, Lyft, Bolt, DoorDash.
- **Recommended approach:** The backend computes the quote (distance and time from a routing API, plus rules and demand), signs it with an expiry, and the app only displays it and sends the quote id back at checkout. Rejected: any pricing logic in the client.
- **Effort:** M, 3-7 days. Drives the range: price breakdown screens, expiry and refresh handling, promos.
- **Depends on:** Backend, routing service (see Places, geocoding, directions below). Google's Compute Routes returns `distanceMeters`, `duration` and an encoded polyline for the fields you request in a field mask; plain requests bill at the Essentials tier (10,000 free, then $5 per 1,000), while traffic-aware routing (`TRAFFIC_AWARE`) bills at the Pro tier (5,000 free, then $10 per 1,000 up to 100,000 events).
- **Android/iOS differences:** None.
- **Custom work after the package:** Quote screen, countdown and re-quote on expiry, breakdown sheet, currency formatting.
- **Pitfalls and store review:** Estimate versus final price mismatches cause support load; show "estimated" wording (judgment). Verify local price-display regulations. Traffic-aware quotes cost double per request, so cache quotes by route.
- **What to tell the requester:** The app part is small; pricing rules are a business and backend task. Ask for the formula and whether prices are locked.
- **Status:** Partly verified 2026-10-31 from https://developers.google.com/maps/documentation/routes/usage-and-billing, https://developers.google.com/maps/documentation/routes/compute_route_directions and https://developers.google.com/maps/billing-and-pricing/pricing. Quote design is judgment; price-display regulations unverified (Verify).

### Recommendations and personalisation
<!-- meta: size=M; days=4-8; deps=flutter-only, backend; platform-difference=none -->
- **Brief:** Personalised home feeds, "because you bought" carousels, and ranking.
- **Seen in:** Netflix, Amazon, Spotify, Uber Eats.
- **Recommended approach:** Ranking lives on the server (own model, or a hosted vendor). Algolia Recommend offers frequently bought together, related items, trending items and looking-similar models; the models need event history (for example 1,000 or more conversion events for frequently bought together, 250 or more for trending), return up to 30 items and retrain once daily. Its overview page names no Flutter client, and the algolia_helper_flutter page does not mention Recommend, so plan to call it from your backend (client options Verify). Flutter renders sectioned feeds from a server-driven layout and logs impressions and taps (judgment). Rejected: on-device ranking, except for trivial "recently viewed".
- **Effort:** M, 4-8 days for the client; model work is separate.
- **Depends on:** Backend and data pipeline; possibly a paid service (Algolia Recommend pricing not stated on the page opened, Verify).
- **Android/iOS differences:** None.
- **Custom work after the package:** Section renderer, lazy loading, impression tracking, skeleton loaders, feedback actions ("not interested").
- **Pitfalls and store review:** Apple's user privacy page defines tracking as linking your app's data with other companies' data for targeted advertising or advertising measurement, or sharing it with data brokers, and requires App Tracking Transparency permission for that. It does not explicitly address first-party personalisation, but it warns that a third-party analytics or advertising SDK can bring your data into scope. Privacy-law consent (for example in the European Union) is unverified (Verify).
- **What to tell the requester:** The UI is easy; relevance quality needs data and time. Do not promise Netflix-level results at launch.
- **Status:** Partly verified 2026-10-31 from https://www.algolia.com/doc/guides/algolia-recommend/overview/, https://pub.dev/packages/algolia_helper_flutter and https://developer.apple.com/app-store/user-privacy-and-data-use/. Feed design is judgment; Algolia pricing, Flutter access and privacy-law consent unverified (Verify).

## Maps, places and routing

### Maps
<!-- meta: size=M; days=3-7; deps=flutter-only, third-party-sdk, paid-service; platform-difference=significant -->
- **Brief:** Interactive map with markers, polylines, clustering and camera control.
- **Seen in:** Uber, Airbnb, DoorDash, Google Maps.
- **Recommended approach:** google_maps_flutter 2.19.0 (flutter.dev, published 2026-10-14; Android SDK 24+, iOS 15+, BSD-3-Clause), including built-in marker clustering through `clusterManagers`. Use Mapbox (mapbox_maps_flutter 3.33.0, published 2026-10-16, needs Flutter 3.38.1+, Android minSdk 21, iOS 14) for custom styles, or flutter_map 8.3.2 (fleaflet.dev) for vendor-free tiles. Rejected: apple_maps_flutter 1.4.0 (iOS only, published 2025-01-23, "developers preview"); google_maps_cluster_manager 3.1.0 (last published 2024-01-16, now unnecessary).
- **Effort:** M, 3-7 days. Drives the range: custom markers, clustering, styling, many pins.
- **Depends on:** Maps API key and billing account (paid service); no backend.
- **Android/iOS differences:** Significant: separate keys and setup per platform; the default iOS implementation is flagged legacy without Swift Package Manager support, with SDK 9/10 variants recommended; `PinConfig` markers may not show on iOS.
- **Custom work after the package:** Marker icons, bounded-size layout (an unbounded `GoogleMap` throws), permission prompts, camera animation.
- **Pitfalls and store review:** Restrict keys by package name and bundle id. Mobile native maps show as unlimited free per Google's pricing page, but check each API you add.
- **What to tell the requester:** Fully achievable and close to native maps. Ask which provider the brand prefers and whether offline maps are required (not covered here, Verify).
- **Status:** Verified 2026-10-30 from pub.dev pages for google_maps_flutter, flutter_map, mapbox_maps_flutter, apple_maps_flutter, google_maps_cluster_manager and https://developers.google.com/maps/flutter-package/samples/cluster-markers. OSM tile policy and Mapbox pricing unverified (Verify).

### Places, geocoding, directions and ETA
<!-- meta: size=M; days=4-8; deps=flutter-only, backend, third-party-sdk, paid-service; platform-difference=minor -->
- **Brief:** Address autocomplete, converting addresses to coordinates and back, drawing a route and showing an ETA.
- **Seen in:** Uber, Uber Eats, Lyft, Google Maps.
- **Recommended approach:** Autocomplete with flutter_google_places_sdk 0.4.3 (sparta.guru, verified publisher, BSD-3-Clause, about 10 months old at capture; README says it uses each platform's native Places library so the key can be restricted to your app; it does not say whether that is the new or legacy Places SDK, or mention session tokens, so Verify both). Routes and ETA from your backend calling Google's Routes API; the app only draws the returned polyline. For simple geocoding use geocoding 5.0.1 (baseflow.com, MIT, Android, iOS and macOS; platform geocoders, `IO_ERROR` usually means rate limiting). Rejected: flutter_polyline_points 3.1.0 as default (last published 2025-09-20; its README examples put the API key in app code, though it supports both Directions and Routes API).
- **Effort:** M, 4-8 days. Drives the range: backend proxy, session tokens, saved places.
- **Depends on:** Paid Google Maps Platform: Geocoding and Compute Routes Essentials 10,000 free then $5 per 1,000 (up to 100,000 events); traffic-aware Compute Routes is Pro (5,000 free, then $10); Autocomplete requests (new) 10,000 free then $2.83 per 1,000, with session usage listed as unlimited free; legacy Directions still listed. Backend for routing.
- **Android/iOS differences:** Minor: the geocoding README says Android geocoding depends on Google Play Services, which is unavailable in some countries.
- **Custom work after the package:** Debounced autocomplete, recent places, polyline decoding, ETA refresh.
- **Pitfalls and store review:** Google's session token page (legacy Places) says requests without a token are each billed under the Per Request SKU; it does not describe new Places API sessions (Verify).
- **What to tell the requester:** Achievable. Ask expected daily requests, since cost scales with usage.
- **Status:** Verified 2026-10-31 from https://pub.dev/packages/flutter_google_places_sdk, https://pub.dev/packages/geocoding, https://pub.dev/packages/flutter_polyline_points, https://developers.google.com/maps/billing-and-pricing/pricing, https://developers.google.com/maps/documentation/routes/usage-and-billing and the Places session tokens page. Places SDK generation, new-API session billing and exact pub.dev dates for geocoding and the Places package unverified (Verify).

### Order tracking and live status
<!-- meta: size=L; days=10-18; deps=flutter-only, backend, third-party-sdk, paid-service; platform-difference=minor -->
- **Brief:** Status timeline (placed, preparing, on the way) and a live map with the courier's position and ETA.
- **Seen in:** Uber Eats, DoorDash, Instacart, Amazon.
- **Recommended approach:** Push status changes with the transport your backend already has (GraphQL subscriptions or WebSocket; web_socket_channel 3.0.3 was published 2025-04-17 and its page does not mention auto-reconnect, so add your own backoff). Use FCM for background updates (see 04). Show the courier on google_maps_flutter with an animated marker. Rejected: polling every few seconds.
- **Effort:** L, 10-18 days. Drives the range: reconnect and resume, marker interpolation, ETA updates.
- **Depends on:** Backend realtime layer, courier app sending location, maps key.
- **Android/iOS differences:** Minor. iOS: Firebase's Flutter page requires push notifications plus the Background fetch and Remote notifications modes, and an APNs authentication key uploaded to Firebase. Android: Android 7.0 or higher with Google Play services.
- **Custom work after the package:** Timeline widget, state machine, reconnect and catch-up on resume, smoothing, "arriving" notifications.
- **Pitfalls and store review:** The Firebase page says a notification tap opens the app, and `getInitialMessage()` (terminated) and `onMessageOpenedApp` (background) deliver the message, so route taps to the order screen. Relying on push while backgrounded is judgment; background handlers and message types are not on that page (Verify).
- **What to tell the requester:** Achievable at near parity; smoothness depends on location update frequency from the courier.
- **Status:** Partly verified 2026-10-31 from https://pub.dev/packages/web_socket_channel (3.0.3, 2025-04-17, tools.dev publisher, no reconnect mention) and https://firebase.google.com/docs/cloud-messaging/flutter/client. Design is judgment; map marker animation not tested (Verify).

### Ride-sharing driver tracking
<!-- meta: size=L; days=15-30; deps=flutter-only, backend, third-party-sdk, paid-service, native-android, native-ios, store-approval; platform-difference=significant -->
- **Brief:** The driver app streams location; the rider sees the car move, with matching, ETA and trip states.
- **Seen in:** Uber, Lyft, Bolt.
- **Recommended approach:** Driver app: geolocator with a foreground service on Android and the location background mode on iOS (setup in 04). Rider app: realtime channel plus map marker interpolation. Matching and dispatch are backend. Rejected: building matching in the app.
- **Effort:** L, 15-30 days for rider plus driver apps. Drives the range: dispatch states, reconnects, battery tuning, turn-by-turn (not included).
- **Depends on:** Backend dispatch and realtime, routing and maps services, native background configuration, App Review justification for background location.
- **Android/iOS differences:** Significant: `ACCESS_BACKGROUND_LOCATION` and foreground service on Android; Always authorization and background mode on iOS (see 04).
- **Custom work after the package:** Trip state machine, offline queue of location points, throttling by distance, in-app navigation hand-off.
- **Pitfalls and store review:** Apple may reject unjustified background location (see 04). In-app turn-by-turn: `google_navigation_flutter` 0.11.2 (Google, Apache-2.0, beta until 1.0) needs Android API 24 or later, iOS 16 or later with Swift Package Manager (CocoaPods unsupported), the background location mode and a Google Cloud API key restricted to the Navigation SDK and Maps SDKs; the user must accept Google's navigation terms in the app, and Mobility Services need a conversation with Google sales. The alternative is a hand-off to the maps app. A Mapbox navigation option: Verify.
- **What to tell the requester:** Core tracking is feasible; a full Uber clone is a product, not a feature. Ask whether navigation, pooling and payments are in scope.
- **Status:** Partly verified 2026-11-01 for Google navigation from https://pub.dev/packages/google_navigation_flutter; tracking parts reuse 04. Verify: Mapbox navigation, Google Mobility Services pricing, matching and dispatch design (judgment).

## Background tracking and field work

### Background location tracking and geofencing
<!-- meta: size=M; days=4-10; deps=flutter-only, third-party-sdk, paid-service, native-android, native-ios, store-approval; platform-difference=significant -->
- **Brief:** Continuous location while the app is not visible, plus region enter/exit triggers.
- **Seen in:** Uber (driver), Life360, Strava, Starbucks (arrival triggers, unverified).
- **Recommended approach:** geolocator for ordinary tracking, as set out in `04-notifications-background-location.md`. For battery-aware motion detection and managed geofences, flutter_background_geolocation 5.9.0 (transistorsoft.com, published 2026-10-09). Its page says a paid licence is required for release builds on both iOS and Android (free in debug, 30-day trial). Rejected: early community geofencing packages (see 04).
- **Effort:** M, 4-10 days. Drives the range: battery testing on real devices.
- **Depends on:** Native permission setup, paid licence for the commercial SDK, store justification.
- **Android/iOS differences:** Significant: about 100 regions on Android, 20 on iOS (from 04).
- **Custom work after the package:** Upload batching, privacy controls, permission education screens.
- **Pitfalls and store review:** Do not declare background location you do not need (see 04).
- **What to tell the requester:** Feasible; iOS limits on regions and background time are firm.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/flutter_background_geolocation; the rest follows 04.

### Logistics, fleet and field-service tracking
<!-- meta: size=L; days=15-30; deps=flutter-only, backend, third-party-sdk, native-android, native-ios, store-approval; platform-difference=significant -->
- **Brief:** Drivers or technicians with job lists, proof of delivery (signature, photo, barcode), offline work and live location for dispatchers.
- **Seen in:** FedEx, Samsara-style fleet apps, ServiceTitan.
- **Recommended approach:** Combine the background tracking entry above, a local database with a sync queue, signature and barcode packages from the utilities inventory, and a dispatcher web dashboard. For managed background tracking use `flutter_background_geolocation` (paid licence for release builds, see the entry above). Maps via google_maps_flutter.
- **Effort:** L, 15-30 days. Drives the range: offline sync and conflict handling.
- **Depends on:** Backend with job assignment, background location, store justification.
- **Android/iOS differences:** Significant background rules (see 04).
- **Custom work after the package:** Offline sync, proof-of-delivery flow, route ordering (backend), battery policy.
- **Pitfalls and store review:** Employee tracking needs clear consent and privacy wording (Verify).
- **What to tell the requester:** Feasible; scope offline behaviour and OS background limits before promising continuous tracking.
- **Status:** Partly verified 2026-11-01: the tracking package and its licence come from https://pub.dev/packages/flutter_background_geolocation; the rest combines the entries above and is judgment. Verify: employee-tracking consent rules by region.
