# 1. Data sharing and linking

Android handles incoming shares and links with manifest intent filters; iOS needs a separate Share Extension target, App Groups and an associated-domains file. The Flutter side is usually one package per job.

| Goal | Android | iOS | Flutter package |
|---|---|---|---|
| Share out (system share sheet) | `ACTION_SEND` intent | `UIActivityViewController` | [share_plus 13.3.1](https://pub.dev/packages/share_plus) |
| Receive shared text, images, files | `intent-filter` for `SEND` / `SEND_MULTIPLE` + MIME types in `AndroidManifest.xml` | Share Extension target + App Group; the extension stores the data, then opens the host app | [receive_sharing_intent 1.9.0](https://pub.dev/packages/receive_sharing_intent) |
| Open app from an https link | App Links: `intent-filter` with `android:autoVerify` + hosted `assetlinks.json` | Universal Links: Associated Domains capability + hosted `apple-app-site-association` | [app_links 7.2.2](https://pub.dev/packages/app_links), or Flutter's built-in handler with a router |
| Open app from a custom scheme | `intent-filter` with `VIEW` + scheme | `CFBundleURLTypes` in `Info.plist` | app_links |
| Share data between app and extension | Not needed: the intent opens your activity directly | App Group container (`UserDefaults` suite, files, database) | [shared_preference_app_group](https://pub.dev/packages/shared_preference_app_group), path_provider, sqflite |

### Share out with share_plus

Call `SharePlus.instance.share(ShareParams(text: ..., files: [...]))`. It returns a result with a status you can check. On iPad the sheet is a popover, so pass `sharePositionOrigin` from the button's render box. Meta apps (Facebook, Messenger) do not reliably accept shares from this plugin on either platform; use the native Facebook Sharing SDK if you need them. Requires Flutter 3.38.1+ and Android Gradle Plugin 8.12.1+ ([share_plus docs](https://pub.dev/packages/share_plus)).

### Receive shares (Android)

Add one `intent-filter` per content type inside `MainActivity`: `SEND` for `text/*`, `image/*`, `video/*` or `*/*`, and `SEND_MULTIPLE` for several files. The plugin docs suggest `android:launchMode="singleTask"` so a new share reuses the running activity instead of creating another ([receive_sharing_intent docs](https://pub.dev/packages/receive_sharing_intent)).

### Receive shares (iOS)

This is the big difference. The plugin's setup, in order:

1. In Xcode, add a **Share Extension** target; give Runner and the extension the same deployment target.
2. Replace the extension's `Info.plist` with the activation rules (`NSExtensionActivationSupportsText`, `...ImageWithMaxCount`, `...MovieWithMaxCount`, `...FileWithMaxCount`) and an `AppGroupId` key.
3. In Runner's `Info.plist`, add `AppGroupId` and a `CFBundleURLSchemes` entry of `ShareMedia-$(PRODUCT_BUNDLE_IDENTIFIER)`.
4. Add the **App Groups** capability to both targets, using one group id, and set a `CUSTOM_GROUP_ID` build setting on both.
5. The plugin ships as a Swift Package only: run `flutter config --enable-swift-package-manager`, then link the `receive-sharing-intent` library to the extension target.
6. Move **Embed Foundation Extensions** above **Thin Binary** (Flutter's own guide says above **Run Script**) in Runner's Build Phases.
7. Make `ShareViewController` inherit from `RSIShareViewController`, and adopt a `SceneDelegate` as newer iOS versions deliver shared URLs through it.

The extension and the app never talk directly, and the app may not be running while the user shares ([Flutter app extensions guide](https://docs.flutter.dev/platform-integration/ios/app-extensions)). The plugin's workaround is saving the payload to the App Group, then opening the app through the custom scheme.

Dart side, read both the stream (app running) and the initial media (cold start):

```dart
final sub = ReceiveSharingIntent.instance.getMediaStream().listen(handleFiles);
ReceiveSharingIntent.instance.getInitialMedia().then((files) {
  handleFiles(files);
  ReceiveSharingIntent.instance.reset(); // tell the plugin you are done
});
```

### Open the app from a web link

Flutter 3.27+ handles deep links by default and feeds them to your router (for example go_router), so no plugin is needed unless you want one. If you use app_links or a similar plugin, turn the default handler off: `flutter_deeplinking_enabled` = false in `AndroidManifest.xml`, `FlutterDeepLinkingEnabled` = NO in `Info.plist` ([deep linking docs](https://docs.flutter.dev/ui/navigation/deep-linking)).

**Android App Links.** Add inside `MainActivity`:

```xml
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="http" android:host="example.com" />
  <data android:scheme="https" />
</intent-filter>
```

Host `https://example.com/.well-known/assetlinks.json` with your package name and the SHA-256 fingerprint of the signing key. With Google Play App Signing, copy the fingerprint from Play Console under App Integrity; list one fingerprint per flavor ([Android cookbook](https://docs.flutter.dev/cookbook/navigation/set-up-app-links)).

**iOS Universal Links.** Add the **Associated Domains** capability with `applinks:example.com` (it writes `Runner.entitlements`). Host `https://example.com/.well-known/apple-app-site-association`, with no `.json` extension:

```json
{
  "applinks": {
    "details": [{
      "appIDs": ["TEAMID.com.example.app"],
      "components": [{ "/": "/*" }]
    }]
  }
}
```

The app id is `<team id>.<bundle id>`. Personal development teams cannot use Associated Domains ([iOS cookbook](https://docs.flutter.dev/cookbook/navigation/set-up-universal-links)).

**Testing.**

|  | Android | iOS |
|---|---|---|
| Test app config only | `adb shell 'am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "http://example.com/details"' <package>` | `xcrun simctl openurl booted https://example.com/details` |
| Test the full web + app setup | Tap the link in another app or a document | Tap the link in the Notes app on a device |

The adb command launches the app even if the hosted file is missing, so it does not prove verification works.

### Pitfalls

- Apple's CDN can take up to 24 hours to fetch a new `apple-app-site-association` file, so a fresh setup may fail at first.
- iOS extensions have tight memory limits. If you render Flutter UI inside one, Flutter advises at least 100 MB of available memory, and debug mode only works on the simulator, not on physical devices.
- In an iOS extension, Flutter views do not handle scroll gestures by default; Flutter's guide links a workaround.
- Two link-handling libraries fight over the same URL. receive_sharing_intent's docs show a `SceneDelegate` workaround for when another library (such as a branch SDK) absorbs its links.
- Verification failures on Android are usually a wrong fingerprint, a missing flavor fingerprint, or the file not served at the exact `/.well-known/` path.

---

Back to the [index](README.md). Sources for all sections are listed there.
