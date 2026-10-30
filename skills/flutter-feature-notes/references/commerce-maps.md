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
- **Recommended approach:** Server-owned cart (the backend calculates totals, tax, shipping and discounts) and a thin Flutter state layer; payment through flutter_stripe PaymentSheet and the `pay` wallet buttons, as in `02-payments-and-subscriptions.md`. Rejected: client-side totals (tamperable) and the store billing API for physical goods.
- **Effort:** L, 10-20 days. Drives the range: guest carts and merging on login, address book, promo rules, payment edge cases, order idempotency.
- **Depends on:** Backend (mostly), paid payment processor, Apple Pay merchant setup and Google Pay Business Console.
- **Android/iOS differences:** Minor: Apple Pay and Google Pay setup, Stripe activity theme on Android (see 02).
- **Custom work after the package:** Cart persistence, optimistic updates, stock-conflict handling, retry-safe order submission, 3-D Secure return handling.
- **Pitfalls and store review:** Physical goods must not use in-app purchase (guideline 3.1.3(e), see 02). Verify tax and invoice rules per country.
- **What to tell the requester:** Achievable at near parity with big retailers. Ask who calculates tax and shipping, which payment methods, and whether guest checkout is needed.
- **Status:** Partly verified (payment facts reused from 02, verified 2026-10-14); cart design is judgment.

### Reviews and ratings
<!-- meta: size=M; days=3-6; deps=flutter-only, backend; platform-difference=none -->
- **Brief:** Star ratings, written reviews with photos, helpful votes and moderation.
- **Seen in:** Amazon, Google Maps, Uber (driver rating), Airbnb.
- **Recommended approach:** Build the star input with built-in widgets; flutter_rating_bar 4.0.1 still works but was last published 2022-05-18, so I would not add a dependency for a 20-line widget. Photo upload via the image picker and your storage backend.
- **Effort:** M, 3-6 days. Drives the range: photos, edit/delete, report flow.
- **Depends on:** Backend with moderation and abuse handling.
- **Android/iOS differences:** None.
- **Custom work after the package:** Rating summary bars, sorting and filtering, accessibility labels (Semantics) for stars, profanity or spam report flow.
- **Pitfalls and store review:** User-generated content needs reporting, blocking and moderation to satisfy Apple guideline 1.2 (Verify wording).
- **What to tell the requester:** Easy on the app side; moderation policy and fake-review prevention are the real work.
- **Status:** Verified 2026-10-30 from https://pub.dev/packages/flutter_rating_bar. Store guideline unverified (Verify).

### Food and grocery menus with modifiers
<!-- meta: size=M; days=5-10; deps=flutter-only, backend; platform-difference=none -->
- **Brief:** Product pages with required and optional choices (size, toppings, substitutions), min/max rules and live price.
- **Seen in:** Uber Eats, DoorDash, Instacart.
- **Recommended approach:** Data-driven forms: the backend sends option groups with rules and prices, Flutter renders them generically and validates locally; the server recomputes the price. No package needed.
- **Effort:** M, 5-10 days. Drives the range: nested modifiers, availability by time, substitutions.
- **Depends on:** Backend schema for option groups.
- **Android/iOS differences:** None.
- **Custom work after the package:** Option-group widgets, validation, sticky price bar, cart line equality (same item, different options), reorder.
- **Pitfalls and store review:** Cart line merging bugs are the usual defect. Verify allergen disclosure rules by country.
- **What to tell the requester:** Achievable, and the schema matters more than the UI. Ask for the most complex menu item you must support.
- **Status:** Unverified (Verify); judgment-based, no sources opened.

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
- **Depends on:** Backend, routing service (see Places, geocoding, directions below).
- **Android/iOS differences:** None.
- **Custom work after the package:** Quote screen, countdown and re-quote on expiry, breakdown sheet, currency formatting.
- **Pitfalls and store review:** Estimate versus final price mismatches cause support load; show "estimated" wording. Verify local price-display regulations.
- **What to tell the requester:** The app part is small; pricing rules are a business and backend task. Ask for the formula and whether prices are locked.
- **Status:** Unverified (Verify); judgment-based.

### Recommendations and personalisation
<!-- meta: size=M; days=4-8; deps=flutter-only, backend; platform-difference=none -->
- **Brief:** Personalised home feeds, "because you bought" carousels, and ranking.
- **Seen in:** Netflix, Amazon, Spotify, Uber Eats.
- **Recommended approach:** Ranking lives on the server (own model, or a vendor such as Algolia Recommend, Verify). Flutter renders sectioned feeds from a server-driven layout and logs impressions and taps. Rejected: on-device ranking, except for trivial "recently viewed".
- **Effort:** M, 4-8 days for the client; model work is separate.
- **Depends on:** Backend and data pipeline; possibly a paid service.
- **Android/iOS differences:** None.
- **Custom work after the package:** Section renderer, lazy loading, impression tracking, skeleton loaders, feedback actions ("not interested").
- **Pitfalls and store review:** Tracking for personalisation can require consent and, on iOS, App Tracking Transparency if it is cross-app (Verify).
- **What to tell the requester:** The UI is easy; relevance quality needs data and time. Do not promise Netflix-level results at launch.
- **Status:** Unverified (Verify).

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
- **Recommended approach:** Autocomplete with flutter_google_places_sdk 0.4.3 (published 2025-12-30; whether it uses the new Places SDK is unconfirmed). Routes and ETA from your backend calling Google's Routes API; the app only draws the returned polyline. For simple reverse geocoding use geocoding 5.0.0 (baseflow.com, 2026-07-03; platform geocoders, `IO_ERROR` signals rate limiting). Rejected: flutter_polyline_points 3.1.0 as default (last published 2025-09-20, puts the API key in app code).
- **Effort:** M, 4-8 days. Drives the range: backend proxy, session tokens, saved places.
- **Depends on:** Paid Google Maps Platform (Geocoding and Compute Routes: 10,000 free then about $5 per 1,000 at the Essentials tier; legacy Directions is still listed); backend for routing.
- **Android/iOS differences:** Minor: Android geocoder depends on Google services availability.
- **Custom work after the package:** Debounced autocomplete, recent places, polyline decoding, ETA refresh.
- **Pitfalls and store review:** Traffic-aware routing may fall in a higher billing tier (Verify). Autocomplete without session tokens costs more (Verify).
- **What to tell the requester:** Achievable. Ask expected daily requests, since cost scales with usage.
- **Status:** Verified 2026-10-30 from the pub.dev pages above and https://developers.google.com/maps/billing-and-pricing/pricing. Places SDK version and tiers unverified (Verify).

### Order tracking and live status
<!-- meta: size=L; days=10-18; deps=flutter-only, backend, third-party-sdk, paid-service; platform-difference=minor -->
- **Brief:** Status timeline (placed, preparing, on the way) and a live map with the courier's position and ETA.
- **Seen in:** Uber Eats, DoorDash, Instacart, Amazon.
- **Recommended approach:** Push status changes with the transport your backend already has (GraphQL subscriptions or WebSocket; web_socket_channel 3.0.3 was published 2025-04-17 and its page does not mention auto-reconnect, so add your own backoff). Use FCM for background updates (see 04). Show the courier on google_maps_flutter with an animated marker. Rejected: polling every few seconds.
- **Effort:** L, 10-18 days. Drives the range: reconnect and resume, marker interpolation, ETA updates.
- **Depends on:** Backend realtime layer, courier app sending location, maps key.
- **Android/iOS differences:** Minor: push setup per 04.
- **Custom work after the package:** Timeline widget, state machine, reconnect and catch-up on resume, smoothing, "arriving" notifications.
- **Pitfalls and store review:** The app is suspended in the background, so rely on push for status changes there.
- **What to tell the requester:** Achievable at near parity; smoothness depends on location update frequency from the courier.
- **Status:** Partly verified (web_socket_channel page, 2026-10-30); design is judgment.

### Ride-sharing driver tracking
<!-- meta: size=L; days=15-30; deps=flutter-only, backend, third-party-sdk, paid-service, native-android, native-ios, store-approval; platform-difference=significant -->
- **Brief:** The driver app streams location; the rider sees the car move, with matching, ETA and trip states.
- **Seen in:** Uber, Lyft, Bolt.
- **Recommended approach:** Driver app: geolocator with a foreground service on Android and the location background mode on iOS (setup in 04). Rider app: realtime channel plus map marker interpolation. Matching and dispatch are backend. Rejected: building matching in the app.
- **Effort:** L, 15-30 days for rider plus driver apps. Drives the range: dispatch states, reconnects, battery tuning, turn-by-turn (not included).
- **Depends on:** Backend dispatch and realtime, routing and maps services, native background configuration, App Review justification for background location.
- **Android/iOS differences:** Significant: `ACCESS_BACKGROUND_LOCATION` and foreground service on Android; Always authorization and background mode on iOS (see 04).
- **Custom work after the package:** Trip state machine, offline queue of location points, throttling by distance, in-app navigation hand-off.
- **Pitfalls and store review:** Apple may reject unjustified background location (see 04). Turn-by-turn in-app needs the Mapbox navigation SDK or a hand-off to the maps app (Verify).
- **What to tell the requester:** Core tracking is feasible; a full Uber clone is a product, not a feature. Ask whether navigation, pooling and payments are in scope.
- **Status:** Partly verified (04 reused); navigation options unverified (Verify).

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
- **Recommended approach:** Combine the background tracking entry above, a local database with a sync queue, signature and barcode packages from the utilities inventory, and a dispatcher web dashboard. Maps via google_maps_flutter.
- **Effort:** L, 15-30 days. Drives the range: offline sync and conflict handling.
- **Depends on:** Backend with job assignment, background location, store justification.
- **Android/iOS differences:** Significant background rules (see 04).
- **Custom work after the package:** Offline sync, proof-of-delivery flow, route ordering (backend), battery policy.
- **Pitfalls and store review:** Employee tracking needs clear consent and privacy wording (Verify).
- **What to tell the requester:** Feasible; scope offline behaviour and OS background limits before promising continuous tracking.
- **Status:** Unverified (Verify); combines entries above.
