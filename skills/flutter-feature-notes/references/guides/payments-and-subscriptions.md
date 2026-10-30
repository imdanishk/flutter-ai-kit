# 2. Payments and subscriptions

What you sell decides the payment path: digital goods unlocked in the app go through the store's billing system, while physical goods and real-world services go through a card or wallet processor.

| What you sell | Payment path | Flutter package |
|---|---|---|
| Subscriptions, premium features, in-game currency | App Store In-App Purchase (iOS), Google Play Billing (Android) | [in_app_purchase 3.3.1](https://pub.dev/packages/in_app_purchase) (Android SDK 24+, iOS 13+) |
| Physical goods or services used outside the app (delivery, ride sharing, e-commerce) | Card or wallet through a payment processor | [flutter_stripe 14.1.0](https://pub.dev/packages/flutter_stripe) |
| Google Pay / Apple Pay buttons | Wallet token sent to your server or processor | [pay 3.3.0](https://pub.dev/packages/pay) |

### Store rules to check first

- Apple guideline 3.1.1 requires In-App Purchase for subscriptions, in-game currencies, premium content and full-version unlocks; guideline 3.1.3(e) covers the opposite case, where physical goods and services used outside the app must use another method ([summary, Oct 2026](https://newly.app/how-to/add-in-app-purchases)).
- Outside the United States, external purchase links for digital goods stay prohibited unless a regional entitlement applies. In the US storefront, links to your own website are allowed after a 2025 court ruling ([flutter_stripe README](https://pub.dev/packages/flutter_stripe), [summary, Oct 2026](https://newly.app/how-to/app-store-external-purchase-link)). Read Apple's current guideline text before shipping, as these rules keep changing.
- Google Play requires Billing Library 8.0.0 or later for new apps and updates since 31 August 2026; developers could request an extension to 1 November 2026. Secondary sources report that Google recommends version 9 ([Android Developers reminder](https://developer.android.com/google/play/billing/additional-resources?hl=hi)). Check which Billing Library version your plugin bundles in its changelog.

### Android vs iOS differences in in_app_purchase

| Topic | Android | iOS |
|---|---|---|
| Store setup | Products, base plans and offers in Play Console | Products and subscription groups in App Store Connect |
| API under the hood | Google Play Billing Library | StoreKit 2 by default; `InAppPurchaseStoreKitPlatform.enableStoreKit1()` falls back to StoreKit 1 |
| Upgrade or downgrade a subscription | Pass `ChangeSubscriptionParam` with a `ReplacementMode` | Not needed; subscription groups handle it |
| Subscription price rise | Legacy price cohorts; Google emails and notifies users | System popup; you can delay it with a payment queue delegate |
| Unfinished purchase | No `completePurchase` within 3 days causes a refund | Transaction is re-delivered on every launch and blocks buying the same product again |
| Restore | `restorePurchases`; consumed consumables are not returned | `restorePurchases`; no API for consumables |
| Offer codes | Handled in Play | `presentCodeRedemptionSheet()` |

For consumables, store the purchase on your own server so you can restore it across devices ([in_app_purchase docs](https://pub.dev/packages/in_app_purchase)).

### The purchase flow, same code on both platforms

1. Start listening to `InAppPurchase.instance.purchaseStream` as early as possible, so purchases from a previous session are caught.
2. Load products with `queryProductDetails(ids)`; handle `notFoundIDs`.
3. Call `buyConsumable` or `buyNonConsumable` with a `PurchaseParam`.
4. On `purchased` or `restored`, verify the receipt on your server, deliver the product, then call `completePurchase`.

```dart
if (details.status == PurchaseStatus.purchased ||
    details.status == PurchaseStatus.restored) {
  final valid = await verifyOnServer(details); // your backend checks with Apple/Google
  if (valid) await deliverProduct(details);
}
if (details.pendingCompletePurchase) {
  await InAppPurchase.instance.completePurchase(details);
}
```

Do not add `com.android.billingclient:billing` to your own `build.gradle`; the plugin warns it can conflict.

### Cards and wallets (physical goods)

**Stripe PaymentSheet.** The server creates the payment intent; the app only holds the publishable key and presents the sheet. Stripe is retiring CardField and CardForm in favor of PaymentSheet, so use PaymentSheet for new work.

|  | Android | iOS |
|---|---|---|
| Required setup for flutter_stripe | `FlutterFragmentActivity` in `MainActivity`, an activity theme descending from `Theme.AppCompat`, Android Gradle Plugin 8+, Kotlin 1.8+, Stripe ProGuard rules | iOS 13+ deployment target, `platform :ios, '13.0'` in the Podfile |
| Wallet | Google Pay: sign up in the Google Pay Business Console | Apple Pay: create a merchant identifier and a payment processing certificate |

**pay package.** `GooglePayButton` and `ApplePayButton` return a payment token that you send to your server or processor. On Android the result arrives through an `EventChannel`, not as a return value. Payment configurations can be loaded from a remote JSON at runtime, which the package recommends ([pay docs](https://pub.dev/packages/pay)).

### Pitfalls

- Redirect-based Stripe methods (iDEAL, PayPal, Link) return through a URL. On iOS with a deep-link plugin, use `app_links` 7.0.0 or newer, make `CFBundleURLSchemes`, `Stripe.urlScheme` and the PaymentSheet `returnURL` match, and forward Stripe URLs to `Stripe.instance.handleURLCallback()`.
- Test purchases need sandbox or test accounts configured in each store; the plugin's example README lists the store setup steps.
- Never trust the client for entitlement: verify every purchase on your server before unlocking content.

---

Back to the [index](README.md). Sources for all sections are listed there.
