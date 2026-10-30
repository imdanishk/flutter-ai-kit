# 4. Notifications, background work and location

Push, scheduled work and live location look similar in Dart but need very different native setup: Android mostly asks for manifest permissions and a foreground service, while iOS asks for Xcode capabilities, background modes and tighter system limits.

| Need | Package | Android | iOS |
|---|---|---|---|
| Push notifications | [firebase_messaging](https://firebase.google.com/docs/cloud-messaging/flutter/get-started) | Android 7.0+ with Google Play services | Push Notifications capability; Background fetch and Remote notifications modes; upload an APNs authentication key (.p8) in the Firebase console; method swizzling must stay on |
| Local and scheduled notifications | [flutter_local_notifications 22.3.2](https://pub.dev/packages/flutter_local_notifications) | `POST_NOTIFICATIONS` runtime request (Android 13+); desugaring and `compileSdk` 35+; boot and alarm receivers for scheduling; exact-alarm permission if timing must be exact | Set `UNUserNotificationCenter` delegate in `AppDelegate`; request permission at a moment you choose; only 64 pending notifications are kept |
| Deferred background tasks | [workmanager 0.10.10](https://pub.dev/packages/workmanager) | Wraps Android WorkManager | Wraps iOS Background Tasks (BGTaskScheduler) |
| Live location | [geolocator 14.1.1](https://pub.dev/packages/geolocator) | `ACCESS_COARSE_LOCATION` / `ACCESS_FINE_LOCATION`; `ACCESS_BACKGROUND_LOCATION` for background (Android 10+); foreground-service notification config | `NSLocationWhenInUseUsageDescription`; for background add the Location updates capability, `NSLocationAlwaysAndWhenInUseUsageDescription` and `UIBackgroundModes` = `location` |
| Geofencing | Community, early versions: [flutter_background_geofencing](https://pub.dev/packages/flutter_background_geofencing), [geofencing_service](https://pub.dev/packages/geofencing_service), [tracelet](https://pub.dev/documentation/tracelet/0.9.1) | Up to 100 regions | Up to 20 regions; "Always" authorization needed; no dwell event |

### Push with Firebase Cloud Messaging

1. Add `firebase_messaging` after setting up Firebase for Flutter.
2. On iOS, enable Push Notifications and the two background modes in Xcode, then upload the APNs key to Firebase.
3. Call `requestPermission()`. On Apple platforms, wait until `getAPNSToken()` returns a value before calling other FCM APIs.
4. Send the device identifier to your backend. The current guide marks the old registration-token APIs as deprecated in favor of Firebase Installation IDs, delivered through the `onRegistered` stream; this needs an opt-in (`firebase_messaging_installation_id_enabled` in the manifest, `FirebaseMessagingInstallationIdEnabled` in `Info.plist`). Do not mix the two approaches ([FCM Flutter guide, updated 2026-10-13](https://firebase.google.com/docs/cloud-messaging/flutter/get-started)).
5. Handle taps in both cases: `getInitialMessage()` when the app was terminated, and the `onMessageOpenedApp` stream when it was in the background. Both are needed for deep-linking from a notification.

### Local notifications

- Scheduling uses the `timezone` package, and exact timing on Android 14+ needs either `SCHEDULE_EXACT_ALARM` (user-granted) or `USE_EXACT_ALARM` (store review applies).
- Some Android makers (Xiaomi, Huawei) stop background apps, so scheduled notifications can silently fail; Samsung reportedly caps alarms at 500. The plugin cannot fix this ([plugin docs](https://pub.dev/packages/flutter_local_notifications)).
- Notification action callbacks that run while the app is closed execute in a separate isolate. The function must be top-level and carry `@pragma('vm:entry-point')`, and iOS needs a plugin-registrant callback in `AppDelegate`.
- The plugin can run alongside firebase_messaging; keep both on recent versions.

### Background work and live location (ride sharing, delivery)

- **Android:** continuous location in the background needs `ACCESS_BACKGROUND_LOCATION` plus a foreground service with a visible notification. geolocator provides `ForegroundNotificationConfig` for this, and merges the Android 14 `FOREGROUND_SERVICE_LOCATION` permission for you.
- **iOS:** requires the Background Modes capability with Location updates, and you must explain it to App Review; Apple can reject the app if the explanation is not convincing. If you only need location while the app is open, set the `BYPASS_PERMISSION_LOCATION_ALWAYS=1` compiler flag so you do not have to declare the "Always" description.
- On Android 12+, request fine and coarse location together, because users can grant only approximate location ([geolocator docs](https://pub.dev/packages/geolocator)).
- For periodic sync or uploads, use workmanager. Tasks run in a Dart entry point marked `@pragma('vm:entry-point')`. Flutter's own extension guide also recommends it for updating iOS extensions such as widgets ([Flutter app extensions guide](https://docs.flutter.dev/platform-integration/ios/app-extensions)).

### Geofencing limits to design around

Android allows about 100 regions per app and iOS 20, with a recommended minimum radius near 100 m. For more regions, swap the active set as the user moves, or use a package that manages that for you ([flutter_background_geofencing](https://pub.dev/packages/flutter_background_geofencing), [geofencing_service](https://pub.dev/packages/geofencing_service)). All geofencing packages found are early versions, so prototype on real devices first.

### Pitfalls

- Android 13+ asks users for notification permission at runtime, so request it at a sensible moment and handle a refusal.
- iOS does not show notifications while the app is in the foreground unless presentation options allow it; the local-notifications plugin enables this by default.
- Test push, background modes and background location on real devices; behavior differs from simulators and from a debug session attached to Xcode.
- Do not declare background location you do not need: on iOS, Apple may question it or reject the app ([geolocator docs](https://pub.dev/packages/geolocator)).

---

Back to the [index](README.md). Sources for all sections are listed there.
