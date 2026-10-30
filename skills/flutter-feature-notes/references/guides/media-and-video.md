# 3. Media and video

Camera, playback and background audio each have a maintained Flutter plugin. Picture-in-Picture and DRM are where Android and iOS diverge most, and both rely on community packages.

| Need | Package | Android | iOS |
|---|---|---|---|
| Camera preview, photo, video recording | [camera 0.12.1](https://pub.dev/packages/camera) | SDK 24+; CameraX implementation by default | iOS 13+; `NSCameraUsageDescription` and `NSMicrophoneUsageDescription` in `Info.plist` |
| Video playback | [video_player 2.14.1](https://pub.dev/packages/video_player) | SDK 24+; ExoPlayer; `INTERNET` permission for network video | iOS 13+; AVPlayer; `NSAppTransportSecurity` entries to play `http` URLs |
| Background audio, lock-screen controls | [audio_service 0.18.19](https://pub.dev/packages/audio_service) with an audio plugin such as just_audio | `WAKE_LOCK`, `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`, plus a service and a media-button receiver in the manifest | `UIBackgroundModes` = `audio` in `Info.plist` |
| Picture-in-Picture | Community: [pip_kit 1.0.2](https://pub.dev/packages/pip_kit), [native_picture_in_picture 1.0.1](https://pub.dev/packages/native_picture_in_picture) | `android:supportsPictureInPicture="true"` on the activity; API 26+ | AVKit; iOS 14 or 15+ depending on the package; does not run in the simulator |
| DRM-protected streaming | Community: [better_player_plus](https://github.com/Segatti/better_player_plus) (Widevine, FairPlay via EZDRM), [better_native_video_player](https://pub.dev/packages/better_native_video_player) | Widevine | FairPlay Streaming (HLS) |

### Camera

- The plugin no longer handles lifecycle for you. Dispose the controller when the app goes `inactive` and re-initialize on `resumed` from `didChangeAppLifecycleState`.
- Permission failures arrive as `CameraException` codes. On iOS, `CameraAccessDeniedWithoutPrompt` means the user must enable access in Settings, because iOS will not show the prompt twice; `CameraAccessRestricted` means parental controls block it.
- Android has two implementations: CameraX (default, better device coverage) and Camera2 (no CameraX limitations). Image streaming while in the background needs extra steps in the CameraX package ([camera docs](https://pub.dev/packages/camera)).

### Video playback

- Supported formats depend on the native player: ExoPlayer on Android and AVPlayer on iOS, so test each format (HLS, DASH, MP4) on both.
- `VideoPlayerController` can render through a texture or, with `videoViewType`, a platform view. Platform views can have correctness issues in some layouts ([video_player docs](https://pub.dev/packages/video_player)).
- For feeds, subtitles, caching and quality tracks, packages like better_player_plus add them on top of video_player.

### Background audio and lock screen

Wrap your audio code in an `AudioHandler`, register it with `AudioService.init(...)` at startup, and broadcast `playbackState` and `mediaItem` so the notification and lock screen stay correct.

- Android 12+: restarting a foreground service from the background can throw `ForegroundServiceStartNotAllowedException`. Set `androidStopForegroundOnPause` to false, or ask users to disable battery optimization.
- iOS: the `audio` background mode only keeps the app alive while audio plays. For silence between tracks, play a silent track rather than idling on a timer.
- Use the `audio_session` package to declare the app's audio role so other apps pause or duck correctly. Do not combine audio_service with other plugins that also manage notifications, lock screen or background audio ([audio_service docs](https://pub.dev/packages/audio_service)).

### Picture-in-Picture

The two systems differ and no package fully hides it. On Android the system shows the activity itself in a small window. On iOS, AVKit owns PiP and needs native video content: pip_kit requires the player to render through an `AVPlayerLayer`, and native_picture_in_picture notes that Flutter's `video_player` texture cannot be shown in an iOS PiP window ([pip_kit](https://pub.dev/packages/pip_kit), [native_picture_in_picture](https://pub.dev/packages/native_picture_in_picture)). Android auto-PiP shows whatever the activity looks like when backgrounded, which is the Flutter UI, not your video, so enter PiP explicitly from a video screen. Check how mature a PiP package is before depending on it; the ones found here are early versions.

### DRM

FairPlay (iOS) and Widevine (Android) use different license request formats, so your license server and backend must support both. FairPlay needs a certificate URL; Widevine needs a license URL. Test DRM on physical devices ([better_native_video_player](https://pub.dev/packages/better_native_video_player)). Axinom's docs note that the original Better Player forced Widevine L3 even where L1 was available; if you need L1 for HD, verify the security level on a device with the package you pick ([Axinom](https://96.docs.axinom.com/services/drm/players/flutter/)).

### Pitfalls

- Missing `Info.plist` usage descriptions crash the app on iOS when it first touches the camera or microphone.
- Test background audio, PiP and DRM on real devices; simulators and emulators do not behave the same.
- Plain `http` video fails on iOS unless you add App Transport Security exceptions, and on Android you need the `INTERNET` permission.

---

Back to the [index](README.md). Sources for all sections are listed there.
