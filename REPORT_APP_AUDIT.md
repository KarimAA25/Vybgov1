# 1) Executive Summary (1 page max)

**What this app is (3 bullets)**
- Multi‑app ride‑hailing platform with separate Driver, Customer, and Admin Flutter apps, each with its own routes and UI flows. Evidence: [driver/lib/app/routes/app_pages.dart](driver/lib/app/routes/app_pages.dart), [customer/lib/app/routes/app_pages.dart](customer/lib/app/routes/app_pages.dart), [admin/lib/app/routes/app_pages.dart](admin/lib/app/routes/app_pages.dart).
- Firebase‑backed system (Auth, Firestore, Storage, Messaging) with Firebase config embedded in Flutter and web code. Evidence: [driver/lib/firebase_options.dart](driver/lib/firebase_options.dart), [customer/lib/firebase_options.dart](customer/lib/firebase_options.dart), [admin/lib/firebase_options.dart](admin/lib/firebase_options.dart), [admin/firebase.js](admin/firebase.js), [firebase.json](firebase.json).
- Payments, mapping, location, and notifications integrated via Flutter packages (Stripe, Razorpay, Google Maps, geolocation, local notifications). Evidence: [driver/pubspec.yaml](driver/pubspec.yaml), [customer/pubspec.yaml](customer/pubspec.yaml).

**Current maturity level: MVP (not production‑ready)**
- Core flows exist (auth, rides, wallet, support, admin dashboards) but test coverage is only default widget tests. Evidence: [driver/test/widget_test.dart](driver/test/widget_test.dart), [customer/test/widget_test.dart](customer/test/widget_test.dart), [admin/test/widget_test.dart](admin/test/widget_test.dart).
- Security posture is not production‑ready due to open Firestore rules and checked‑in service account keys + database dump. Evidence: [admin/firestore.rules](admin/firestore.rules), [Database/config.json](Database/config.json), [Database/database.json](Database/database.json).
- Cloud Functions are stubbed (no business logic). Evidence: [functions/index.js](functions/index.js).

**Top 10 risks (ranked by severity × likelihood)**
1. **Open Firestore access** (read/write allowed for all documents). Evidence: [admin/firestore.rules](admin/firestore.rules) excerpt: “allow read, write: if true;”.
2. **Service account private key committed** (full admin access). Evidence: [Database/config.json](Database/config.json) excerpt: “private_key”.
3. **Full Firestore data dump committed** (PII and business data exposure). Evidence: [Database/database.json](Database/database.json) contains full collections.
4. **No CI quality gates** (lint/test/build not enforced). Not found; searched for CI configs and found only node_modules entries: [package.json](package.json) and search output.
5. **Functions backend empty** (no server‑side enforcement or logic). Evidence: [functions/index.js](functions/index.js) is only template comments.
6. **No Crash/Analytics in mobile apps** (no crashlytics/sentry/etc.). Not found; searched for “crashlytics|sentry|bugsnag” across codebase.
7. **Mixed state management patterns** (GetX + Provider) increases complexity and inconsistencies. Evidence: [driver/lib/main.dart](driver/lib/main.dart), [customer/lib/main.dart](customer/lib/main.dart), [admin/lib/main.dart](admin/lib/main.dart).
8. **Realtime listeners without lifecycle control** (risk of leaks). Evidence: [customer/lib/utils/fire_store_utils.dart](customer/lib/utils/fire_store_utils.dart) excerpt: “snapshots().listen(…)” in `getSharingPersonsList()` with no cancellation.
9. **Hard‑coded external URLs and keys in code** (cannot rotate easily). Evidence: [driver/lib/constant/constant.dart](driver/lib/constant/constant.dart) excerpt contains hosted asset URLs; Firebase keys in [driver/lib/firebase_options.dart](driver/lib/firebase_options.dart).
10. **No environment separation** (dev/stage/prod) detected. Not found; searched for flavors/env files. Evidence: no .env files found (search), and single Firebase project in [firebase.json](firebase.json).

**Go/No‑Go recommendation for production release**
**No‑Go** until security issues (open rules, service keys, data dumps) are remediated and at least minimal CI/testing + crash monitoring are added. Evidence: [admin/firestore.rules](admin/firestore.rules), [Database/config.json](Database/config.json), [Database/database.json](Database/database.json), [functions/index.js](functions/index.js).

---

# 2) Architecture Overview

**High‑level system diagram (ASCII)**

```
[Driver App]    [Customer App]    [Admin Web/App]
     |                |                 |
     | Firebase Auth  | Firebase Auth   | Firebase Auth
     | Firestore CRUD | Firestore CRUD  | Firestore CRUD
     | Storage/FCM    | Storage/FCM     | Storage/FCM
     | Maps/Payments  | Maps/Payments   | Admin config
     +---------+------+--------+--------+
               |               
           [Firebase Project: vybgo-c2ee0]
               |
        [Cloud Functions (stub)]
```

Evidence for Firebase config: [driver/lib/firebase_options.dart](driver/lib/firebase_options.dart), [customer/lib/firebase_options.dart](customer/lib/firebase_options.dart), [admin/lib/firebase_options.dart](admin/lib/firebase_options.dart), [firebase.json](firebase.json).

**Core modules/layers**
- Presentation: GetX route modules under `app/modules` for each app. Evidence: [driver/lib/app/routes/app_pages.dart](driver/lib/app/routes/app_pages.dart), [customer/lib/app/routes/app_pages.dart](customer/lib/app/routes/app_pages.dart), [admin/lib/app/routes/app_pages.dart](admin/lib/app/routes/app_pages.dart).
- Domain/Data: Firestore utilities + model classes in `app/models` and `utils/fire_store_utils.dart`. Evidence: [driver/lib/utils/fire_store_utils.dart](driver/lib/utils/fire_store_utils.dart), [customer/lib/utils/fire_store_utils.dart](customer/lib/utils/fire_store_utils.dart), [admin/lib/app/utils/fire_store_utils.dart](admin/lib/app/utils/fire_store_utils.dart).
- Shared settings/constants: `constant/constant.dart` (driver/customer) and `app/constant/constants.dart` (admin). Evidence: [driver/lib/constant/constant.dart](driver/lib/constant/constant.dart), [customer/lib/constant/constant.dart](customer/lib/constant/constant.dart), [admin/lib/app/constant/constants.dart](admin/lib/app/constant/constants.dart).

**Data flow: auth → user session → main features**
- Auth via Firebase Auth with phone OTP and Google/Apple sign‑in (driver/customer), and email/password (admin). Evidence: [driver/lib/app/modules/login/controllers/login_controller.dart](driver/lib/app/modules/login/controllers/login_controller.dart), [customer/lib/app/modules/login/controllers/login_controller.dart](customer/lib/app/modules/login/controllers/login_controller.dart), [admin/lib/app/modules/login_page/controllers/login_page_controller.dart](admin/lib/app/modules/login_page/controllers/login_page_controller.dart).
- Session check via `FirebaseAuth.instance.currentUser` in Firestore utilities. Evidence: [driver/lib/utils/fire_store_utils.dart](driver/lib/utils/fire_store_utils.dart), [customer/lib/utils/fire_store_utils.dart](customer/lib/utils/fire_store_utils.dart), [admin/lib/app/utils/fire_store_utils.dart](admin/lib/app/utils/fire_store_utils.dart).
- App routes and module flows in `AppPages`. Evidence: [driver/lib/app/routes/app_pages.dart](driver/lib/app/routes/app_pages.dart), [customer/lib/app/routes/app_pages.dart](customer/lib/app/routes/app_pages.dart), [admin/lib/app/routes/app_pages.dart](admin/lib/app/routes/app_pages.dart).

**External services (where configured)**
- Firebase Auth/Firestore/Storage/Messaging: Dependencies in Flutter apps. Evidence: [driver/pubspec.yaml](driver/pubspec.yaml), [customer/pubspec.yaml](customer/pubspec.yaml), [admin/pubspec.yaml](admin/pubspec.yaml).
- Firebase project configuration: [firebase.json](firebase.json), [admin/firebase.js](admin/firebase.js).
- Google Maps + Geo services: `google_maps_flutter`, `geolocator`, `geocoding`, `geoflutterfire2`. Evidence: [driver/pubspec.yaml](driver/pubspec.yaml), [customer/pubspec.yaml](customer/pubspec.yaml).
- Payments: `flutter_stripe`, `razorpay_flutter`, `mp_integration`. Evidence: [driver/pubspec.yaml](driver/pubspec.yaml), [customer/pubspec.yaml](customer/pubspec.yaml).
- Notifications: `firebase_messaging`, `flutter_local_notifications`. Evidence: [driver/pubspec.yaml](driver/pubspec.yaml), [customer/pubspec.yaml](customer/pubspec.yaml).

---

# 3) Repository Map

**Tree‑style map (top level)**
```
vybgo/
  admin/            # Admin Flutter web/app
  customer/         # Customer Flutter app
  driver/           # Driver Flutter app
  functions/        # Firebase Cloud Functions (Node)
  Database/         # Firestore export/import scripts + data
  firestore_index/  # Firestore rules + indexes
  android/ ios/ ... # Flutter platform folders
  lib/              # Root Flutter template app
  web/              # Root Flutter web
  lending_page/     # Static landing page
  html_editor_enhanced/ # Local package used by admin
  build/ node_modules/ # Build and dependency outputs
```
Evidence: root directory listing captured from workspace.

**Folder responsibilities**
- Admin: web/admin tooling and settings. Evidence: [admin/lib/main.dart](admin/lib/main.dart) and [admin/lib/app/routes/app_pages.dart](admin/lib/app/routes/app_pages.dart).
- Customer: rider experience app. Evidence: [customer/lib/main.dart](customer/lib/main.dart) and [customer/lib/app/routes/app_pages.dart](customer/lib/app/routes/app_pages.dart).
- Driver: driver experience app. Evidence: [driver/lib/main.dart](driver/lib/main.dart) and [driver/lib/app/routes/app_pages.dart](driver/lib/app/routes/app_pages.dart).
- Database: Firestore export/import and service account. Evidence: [Database/export.js](Database/export.js), [Database/import.js](Database/import.js), [Database/config.json](Database/config.json).
- Functions: Cloud Functions scaffold only. Evidence: [functions/index.js](functions/index.js).

**Dead/unused folders or suspicious duplicates**
- Root app (`lib/` and `test/`) is default Flutter counter app; appears unused relative to customer/driver/admin apps. Evidence: [lib/main.dart](lib/main.dart), [test/widget_test.dart](test/widget_test.dart).
- Duplicate Firestore rules: open rules in [admin/firestore.rules](admin/firestore.rules) vs locked‑down rules in [firestore_index/firestore.rules](firestore_index/firestore.rules).
- Zipped duplicates: Database.zip, firestore_index.zip, mytaxi-documention.zip at repo root. Evidence: root listing.
- Build artifacts and node_modules are committed: [build](build), [node_modules](node_modules), [admin/build](admin/build) etc.

---

# 4) Product Features Inventory

> The features below are inferred from route/module names and Firestore data structures. Each item references the route definitions or utilities where it appears.

## Driver app features
- **Authentication (phone OTP, Google, Apple)**
  - Entry points: `LoginView`, `VerifyOtpView` routes. Evidence: [driver/lib/app/routes/app_pages.dart](driver/lib/app/routes/app_pages.dart).
  - Data models: `DriverUserModel`. Evidence: [driver/lib/app/modules/login/controllers/login_controller.dart](driver/lib/app/modules/login/controllers/login_controller.dart).
  - APIs: Firebase Auth. Evidence: [driver/lib/app/modules/login/controllers/login_controller.dart](driver/lib/app/modules/login/controllers/login_controller.dart).
  - Status: working (client side). Gaps: server‑side checks and App Check not configured (not found).

- **Ride management (cab, intercity, rental, parcel)**
  - Entry points: `CabRidesView`, `InterCityRidesView`, `RentalRidesView`, `ParcelRideForHomeView`. Evidence: [driver/lib/app/routes/app_pages.dart](driver/lib/app/routes/app_pages.dart).
  - Data models/collections: `bookings`, `intercity_ride`, `rental_ride`, `parcel_ride`. Evidence: [driver/lib/constant/collection_name.dart](driver/lib/constant/collection_name.dart).
  - APIs: Firestore CRUD in `FireStoreUtils`. Evidence: [driver/lib/utils/fire_store_utils.dart](driver/lib/utils/fire_store_utils.dart).
  - Status: partial (requires backend rules and validation).

- **Wallet & payouts**
  - Entry points: `MyWalletView`, `MyBankView`, `AddBankView`, `PayoutRequest` features via collections. Evidence: [driver/lib/app/routes/app_pages.dart](driver/lib/app/routes/app_pages.dart), [driver/lib/constant/collection_name.dart](driver/lib/constant/collection_name.dart).
  - Data model: `wallet_transaction`, `bank_details`, `withdrawal_history`. Evidence: [driver/lib/constant/collection_name.dart](driver/lib/constant/collection_name.dart).
  - Status: partial (depends on rules and admin processing).

- **Support & SOS**
  - Entry points: `SupportScreenView`, `CreateSupportTicketView`, `SosRequestView`. Evidence: [driver/lib/app/routes/app_pages.dart](driver/lib/app/routes/app_pages.dart).
  - Data model: `support_ticket`, `sos_alerts`. Evidence: [driver/lib/constant/collection_name.dart](driver/lib/constant/collection_name.dart).
  - Status: partial; needs enforcement of access control.

- **Maps and live tracking**
  - Entry points: `TrackRideScreenView` and variants. Evidence: [driver/lib/app/routes/app_pages.dart](driver/lib/app/routes/app_pages.dart).
  - Dependencies: `google_maps_flutter`, `geolocator`, `geoflutterfire2`. Evidence: [driver/pubspec.yaml](driver/pubspec.yaml).
  - Status: partial; no server‑side location validation.

## Customer app features
- **Authentication (phone OTP, Google, Apple)**
  - Entry points: `LoginView`, `VerifyOtpView`. Evidence: [customer/lib/app/routes/app_pages.dart](customer/lib/app/routes/app_pages.dart).
  - APIs: Firebase Auth. Evidence: [customer/lib/app/modules/login/controllers/login_controller.dart](customer/lib/app/modules/login/controllers/login_controller.dart).
  - Status: working (client side).

- **Booking flows (cab/intercity/parcel/rental)**
  - Entry points: `CabRideView`, `InterCityRidesView`, `ParcelRidesView`, `RentalRidesView`. Evidence: [customer/lib/app/routes/app_pages.dart](customer/lib/app/routes/app_pages.dart).
  - Data model: `bookings`, `intercity_ride`, `parcel_ride`, `rental_ride`. Evidence: [customer/lib/constant/collection_name.dart](customer/lib/constant/collection_name.dart).
  - Status: partial; backend rules need hardening.

- **Wallet, coupons, loyalty, referrals**
  - Entry points: `MyWalletView`, `CouponScreenView`, `LoyaltyPointScreenView`, `ReferralScreenView`. Evidence: [customer/lib/app/routes/app_pages.dart](customer/lib/app/routes/app_pages.dart).
  - Data model: `coupon`, `wallet_transaction`, `loyalty_point_transaction`, `referral`. Evidence: [customer/lib/constant/collection_name.dart](customer/lib/constant/collection_name.dart).
  - Status: partial.

- **Support & SOS**
  - Entry points: `SupportScreenView`, `CreateSupportTicketView`, `SosRequestView`. Evidence: [customer/lib/app/routes/app_pages.dart](customer/lib/app/routes/app_pages.dart).
  - Data model: `support_ticket`, `sos_alerts`. Evidence: [customer/lib/constant/collection_name.dart](customer/lib/constant/collection_name.dart).
  - Status: partial.

- **Chat**
  - Entry points: `ChatScreenView`, `InboxScreenView`. Evidence: [customer/lib/app/routes/app_pages.dart](customer/lib/app/routes/app_pages.dart).
  - Data model: `chat`. Evidence: [customer/lib/constant/collection_name.dart](customer/lib/constant/collection_name.dart).
  - Status: partial.

## Admin app features
- **Admin login and dashboard**
  - Entry points: `LoginPageView`, `DashboardScreenView`. Evidence: [admin/lib/app/routes/app_pages.dart](admin/lib/app/routes/app_pages.dart).
  - APIs: Firebase Auth + admin collection check. Evidence: [admin/lib/app/modules/login_page/controllers/login_page_controller.dart](admin/lib/app/modules/login_page/controllers/login_page_controller.dart).
  - Status: partial; relies on permissive Firestore rules.

- **System configuration**
  - Entry points: `AppSettingsView`, `GeneralSettingView`, `MapSettingsView`, `SmtpSettingsView`. Evidence: [admin/lib/app/routes/app_pages.dart](admin/lib/app/routes/app_pages.dart).
  - Data model: `settings`, `email_template`, `notification` collections. Evidence: [admin/lib/app/constant/collection_name.dart](admin/lib/app/constant/collection_name.dart), [Database/database.json](Database/database.json).
  - Status: working in UI; backend rules missing.

- **User/driver management & verification**
  - Entry points: `DriverScreenView`, `VerifyDriverScreenView`, `CustomersScreenView`. Evidence: [admin/lib/app/routes/app_pages.dart](admin/lib/app/routes/app_pages.dart).
  - Data model: `drivers`, `users`, `documents`. Evidence: [admin/lib/app/constant/collection_name.dart](admin/lib/app/constant/collection_name.dart), [Database/database.json](Database/database.json).
  - Status: partial.

- **Bookings oversight (cab/intercity/parcel/rental)**
  - Entry points: `CabBookingScreenView`, `InterCityHistoryScreenView`, `ParcelHistoryScreenView`, `RentalRideScreenView`. Evidence: [admin/lib/app/routes/app_pages.dart](admin/lib/app/routes/app_pages.dart).
  - Data model: `bookings`, `intercity_ride`, `parcel_ride`, `rental_ride`. Evidence: [admin/lib/app/constant/collection_name.dart](admin/lib/app/constant/collection_name.dart).
  - Status: partial.

---

# 5) Code Health & Maintainability

**Complexity hotspots**
- Very large view and utility files, indicating UI logic density and high coupling.
  - Examples: [admin/lib/app/modules/payment/views/payment_view.dart](admin/lib/app/modules/payment/views/payment_view.dart), [admin/lib/app/utils/fire_store_utils.dart](admin/lib/app/utils/fire_store_utils.dart), [driver/lib/app/modules/parcel_detail_details/views/parcel_booking_details_view.dart](driver/lib/app/modules/parcel_detail_details/views/parcel_booking_details_view.dart).

**Repetition/duplication issues**
- Driver/Customer share nearly identical auth and Firestore utility logic with duplicated code. Evidence: [driver/lib/app/modules/login/controllers/login_controller.dart](driver/lib/app/modules/login/controllers/login_controller.dart) vs [customer/lib/app/modules/login/controllers/login_controller.dart](customer/lib/app/modules/login/controllers/login_controller.dart).
- Duplicate Firestore rules in two locations with conflicting access. Evidence: [admin/firestore.rules](admin/firestore.rules) vs [firestore_index/firestore.rules](firestore_index/firestore.rules).

**State management patterns**
- GetX routing/controllers + Provider for theme in the same app. Evidence: [driver/lib/main.dart](driver/lib/main.dart), [customer/lib/main.dart](customer/lib/main.dart), [admin/lib/main.dart](admin/lib/main.dart).

**Error handling & logging strategy**
- Mostly `log()` / `debugPrint()` / toast messages without structured logging. Evidence: [driver/lib/utils/fire_store_utils.dart](driver/lib/utils/fire_store_utils.dart), [customer/lib/utils/fire_store_utils.dart](customer/lib/utils/fire_store_utils.dart).

**Tech debt list (effort)**
- Harden Firestore rules and remove exposed service keys (L). Evidence: [admin/firestore.rules](admin/firestore.rules), [Database/config.json](Database/config.json).
- Refactor duplicated auth/Firestore logic into shared packages (M). Evidence: [driver/lib/app/modules/login/controllers/login_controller.dart](driver/lib/app/modules/login/controllers/login_controller.dart) vs [customer/lib/app/modules/login/controllers/login_controller.dart](customer/lib/app/modules/login/controllers/login_controller.dart).
- Split oversized view files and move business logic out of UI (M). Evidence: [admin/lib/app/modules/payment/views/payment_view.dart](admin/lib/app/modules/payment/views/payment_view.dart).

---

# 6) Security & Privacy Review

**Auth flow analysis**
- Driver/Customer use phone OTP + Google/Apple sign‑in. Evidence: [driver/lib/app/modules/login/controllers/login_controller.dart](driver/lib/app/modules/login/controllers/login_controller.dart), [customer/lib/app/modules/login/controllers/login_controller.dart](customer/lib/app/modules/login/controllers/login_controller.dart).
- Admin uses email/password with admin‑collection check. Evidence: [admin/lib/app/modules/login_page/controllers/login_page_controller.dart](admin/lib/app/modules/login_page/controllers/login_page_controller.dart).

**Secret management**
- **Critical**: Service account private key committed. Evidence: [Database/config.json](Database/config.json).
- Firebase API keys committed in client code (expected for Firebase but still rotateable). Evidence: [driver/lib/firebase_options.dart](driver/lib/firebase_options.dart), [customer/lib/firebase_options.dart](customer/lib/firebase_options.dart), [admin/firebase.js](admin/firebase.js).

**Rules / access control**
- **Critical**: Firestore rules allow open read/write. Evidence: [admin/firestore.rules](admin/firestore.rules).
- Conflicting rule file in repo denies all access. Evidence: [firestore_index/firestore.rules](firestore_index/firestore.rules).

**Injection risks / unsafe calls**
- No server‑side validation in Functions (not implemented). Evidence: [functions/index.js](functions/index.js).
- Multiple direct Firestore writes from clients; relies entirely on rules. Evidence: [driver/lib/utils/fire_store_utils.dart](driver/lib/utils/fire_store_utils.dart), [customer/lib/utils/fire_store_utils.dart](customer/lib/utils/fire_store_utils.dart), [admin/lib/app/utils/fire_store_utils.dart](admin/lib/app/utils/fire_store_utils.dart).

**PII handling & data exposure**
- Firestore dump committed (contains users, drivers, bookings, etc.). Evidence: [Database/database.json](Database/database.json).

**Concrete fixes (file targets)**
- Replace open rules with least‑privilege rules in [admin/firestore.rules](admin/firestore.rules).
- Remove [Database/config.json](Database/config.json) and [Database/database.json](Database/database.json) from repo and rotate service account keys.
- Add server‑side validation in [functions/index.js](functions/index.js).

---

# 7) Data Layer & Backend Integration

**Database schema/models inferred**
- Collections: `users`, `drivers`, `bookings`, `intercity_ride`, `parcel_ride`, `rental_ride`, `wallet_transaction`, `support_ticket`, `subscription_plans`, `zones`, etc. Evidence: [admin/lib/app/constant/collection_name.dart](admin/lib/app/constant/collection_name.dart), [driver/lib/constant/collection_name.dart](driver/lib/constant/collection_name.dart), [customer/lib/constant/collection_name.dart](customer/lib/constant/collection_name.dart), [Database/database.json](Database/database.json).

**API client patterns**
- Direct Firestore access via static utility classes in each app. Evidence: [driver/lib/utils/fire_store_utils.dart](driver/lib/utils/fire_store_utils.dart), [customer/lib/utils/fire_store_utils.dart](customer/lib/utils/fire_store_utils.dart), [admin/lib/app/utils/fire_store_utils.dart](admin/lib/app/utils/fire_store_utils.dart).

**Realtime subscriptions**
- Firestore `snapshots().listen` used without lifecycle management. Evidence: [customer/lib/utils/fire_store_utils.dart](customer/lib/utils/fire_store_utils.dart) in `getSharingPersonsList()`.

**Offline handling & caching**
- Not found (no explicit offline cache strategy). Searched for “offline”, “cache manager”, and no explicit repo‑level config.
- Cached images used via `cached_network_image`. Evidence: [driver/pubspec.yaml](driver/pubspec.yaml), [customer/pubspec.yaml](customer/pubspec.yaml).

**Migration strategy**
- Not found. No migrations or schema versioning in repo.

---

# 8) Performance & Reliability

**Startup time risks**
- Multiple heavy initializations during app startup (Firebase init + settings fetch). Evidence: [driver/lib/main.dart](driver/lib/main.dart), [admin/lib/main.dart](admin/lib/main.dart), [admin/lib/app/utils/fire_store_utils.dart](admin/lib/app/utils/fire_store_utils.dart) `getSettings()`.

**Rendering jank risks**
- Very large view files (2000+ LOC) likely contain complex build methods. Evidence: [admin/lib/app/modules/payment/views/payment_view.dart](admin/lib/app/modules/payment/views/payment_view.dart), [driver/lib/app/modules/rental_ride_details/views/rental_ride_details_view.dart](driver/lib/app/modules/rental_ride_details/views/rental_ride_details_view.dart).

**Network resilience**
- Not found: no explicit retry/backoff policy for Firestore or Dio. Searched for “retry”, “backoff” across codebase.

**Memory leaks / stream disposal**
- `snapshots().listen` without cancellation (potential leak). Evidence: [customer/lib/utils/fire_store_utils.dart](customer/lib/utils/fire_store_utils.dart).

**Image loading/caching**
- Cached image dependency is present. Evidence: [driver/pubspec.yaml](driver/pubspec.yaml), [customer/pubspec.yaml](customer/pubspec.yaml).

---

# 9) Testing & Quality Gates

**Existing tests**
- Only default widget tests in each app. Evidence: [driver/test/widget_test.dart](driver/test/widget_test.dart), [customer/test/widget_test.dart](customer/test/widget_test.dart), [admin/test/widget_test.dart](admin/test/widget_test.dart).

**Missing critical tests**
- Auth flow tests, booking flow tests, payment and wallet tests. Not found; only default tests present.

**Test flakiness risks**
- UI widget tests rely on default counter logic, not real app flows. Evidence: [driver/test/widget_test.dart](driver/test/widget_test.dart).

**Suggested CI gates**
- Not found in repo. No CI config present; searched for .github/workflows and other CI directories.

---

# 10) Build, Release, and Environments

**Environment separation**
- Not found (single Firebase project, no flavors/env files). Evidence: [firebase.json](firebase.json) and no .env files in repo search.

**Build flavors / config strategy**
- Not found (no flavor definitions in repo). Searched for `flavor` and `--dart-define` usage.

**iOS/Android signing readiness**
- Google services configs exist. Evidence: [firebase.json](firebase.json) outputs to `ios/Runner/GoogleService-Info.plist` and `android/app/google-services.json`.
- No signing keys committed (good), but no documented release signing process found. Not found in README.

**Versioning strategy**
- Version is static in pubspecs (1.0.0+1). Evidence: [pubspec.yaml](pubspec.yaml), [driver/pubspec.yaml](driver/pubspec.yaml), [customer/pubspec.yaml](customer/pubspec.yaml), [admin/pubspec.yaml](admin/pubspec.yaml).

**Crash monitoring readiness**
- Not found (no crash reporting dependencies). Evidence: search for crashlytics/sentry returned none.

---

# 11) DX (Developer Experience)

**Setup steps currently required**
- Default Flutter README only; no project‑specific setup. Evidence: [README.md](README.md), [driver/README.md](driver/README.md), [customer/README.md](customer/README.md), [admin/README.md](admin/README.md).

**Onboarding time estimate**
- 1–2 days for experienced Flutter dev due to multiple apps and Firebase setup; longer without documented steps. Evidence: minimal README files.

**Recommended scripts**
- Provide root scripts for common tasks (run driver/customer/admin, tests, lint). Not found; only Firebase tools dependencies at root [package.json](package.json).

**Missing documentation sections**
- Deployment, environment setup, Firebase project configuration, and app architecture. Not found in [README.md](README.md).

---

# 12) Concrete Action Plan

**Next 72 hours: highest ROI tasks**
1. **Remove secrets and data dump** (Impact: critical security; Effort: S; Owner: backend/devops). Files: [Database/config.json](Database/config.json), [Database/database.json](Database/database.json).
2. **Lock down Firestore rules** (Impact: critical security; Effort: M; Owner: backend). Files: [admin/firestore.rules](admin/firestore.rules), align with [firestore_index/firestore.rules](firestore_index/firestore.rules).
3. **Add minimal CI (lint + tests)** (Impact: quality gate; Effort: M; Owner: devops). Not found; add CI config.
4. **Remove build/node_modules from repo** (Impact: repo hygiene; Effort: S; Owner: devops). Evidence: [build](build), [node_modules](node_modules).
5. **Add crash monitoring (Crashlytics/Sentry)** (Impact: production observability; Effort: M; Owner: mobile). Not found.

**Next 2 weeks: stabilization plan**
- Define environment strategy (dev/stage/prod) and configure Firebase projects. Effort: M; Owner: devops. Evidence: [firebase.json](firebase.json).
- Add core tests (auth, booking flow, payment). Effort: L; Owner: mobile QA. Evidence: minimal tests only.
- Implement backend validation in Cloud Functions. Effort: L; Owner: backend. Evidence: [functions/index.js](functions/index.js).

**Next 2 months: production hardening plan**
- Refactor shared logic into packages and reduce duplication. Effort: L; Owner: mobile.
- Performance optimization for large views and isolate heavy logic. Effort: L; Owner: mobile.
- Formal security review + penetration testing after rules hardened. Effort: M; Owner: security.

---

**Not found summary (where searched)**
- CI configs: searched for `.github`, `.gitlab`, `.circleci` (only in node_modules).
- Environment files: searched for `.env*` and signing key files.
- Crash/analytics SDKs: searched for “crashlytics|sentry|bugsnag|datadog”.
