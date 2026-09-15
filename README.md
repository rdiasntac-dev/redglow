# REDGLOW

REDGLOW is a Flutter + Firebase source-code product for home beauty services.
It is being prepared for code sale, not for immediate commercial operation by
the current owner.

## What is included

- Client and provider app flows.
- Professional catalog with multiple niches and services.
- Service selection by `String` service name.
- Per-service pricing, duration and points.
- Booking lifecycle in Firestore.
- Realtime provider acceptance and service progress.
- Ratings, history, cancellation, identity check, rewards and admin areas.
- Demo checkout with Pix, Card and Cash options.
- APK release build for demonstration.

## Architecture

- Flutter UI in `lib/screens/` and `lib/widgets/`.
- App state in `lib/state/demo_app_state.dart`.
- Marketplace and Firestore access in `lib/services/firebase_marketplace_service.dart`.
- Demo payment abstraction in `lib/services/payment_service.dart`.
- Catalog logic in `lib/models/service_catalog.dart`.
- Firebase bootstrap in `lib/main.dart`.

## Firebase

Current project:

- Firebase project: `redglow-54a5f`
- Android package: `br.com.redglow.app`

Used services:

- Firebase Authentication
- Cloud Firestore
- Firebase Storage

## Local setup

```bash
flutter pub get
```

## Run

```bash
flutter run
```

## Test

```bash
flutter analyze
flutter test
```

## APK release

```bash
flutter build apk --release
```

The release APK is generated at:

`build/app/outputs/flutter-apk/app-release.apk`

## Firebase configuration

1. Install Firebase CLI.
2. Authenticate with your Google account.
3. Select the project `redglow-54a5f`.
4. Publish Firestore rules and indexes only after reviewing them.

Example:

```bash
firebase use redglow-54a5f
firebase deploy --only firestore:rules,firestore:indexes
```

## Storage

Storage is used for profile photos and professional documents. The future
buyer must configure their own Firebase Storage rules and billing plan.

## Android signing

- `applicationId`: `br.com.redglow.app`
- `minSdk`: 24
- `compileSdk` / `targetSdk`: Flutter-managed values in the Android Gradle file.

The APK in this repo uses debug signing for demonstration only. The buyer must
configure production signing before Play Store publication.

## Payment integration

The checkout is prepared for a future gateway through:

- `PaymentMethod`
- `PaymentProvider`
- `MockPaymentProvider`

No real gateway is wired yet. The demo flow does **not** store card number, CVV
or bank credentials.

## Demo-only features

- Payment processing is simulated.
- Pix is demonstrative and does not expose a real key.
- Identity verification is not automatic.
- Subscription, payouts and financial settlement are not real.
- The app includes demo state and demo checkout behavior for sales validation.

## External services the buyer may need

- Firebase project ownership
- Firebase Authentication configuration
- Firestore rules and indexes deployment
- Firebase Storage billing/rules
- Android signing keystore
- Optional real payment gateway
- Optional production geolocation/routing providers

## Build notes

The project is prepared for sale as source code plus a demo APK. The future
buyer should configure:

- their own Firebase project or rebind the existing one;
- production signing;
- any real payment gateway;
- production storage and infrastructure.

