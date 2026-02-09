# Build Status

## Current build commands

### Flutter apps
From repo root:
- Install deps (all apps): `make pub-get`
- Analyze (all apps): `make analyze`
- Test (all apps): `make test`

Per app (direct):
- Driver: `cd driver && flutter pub get && flutter analyze && flutter test`
- Customer: `cd customer && flutter pub get && flutter analyze && flutter test`
- Admin: `cd admin && flutter pub get && flutter analyze && flutter test`

### Functions
- `cd functions && npm ci && npm run lint`

## Known remaining issues (from inspection)
- **Driver/Customer web builds not configured**: `DefaultFirebaseOptions` throws UnsupportedError for web. Building for web will fail until FlutterFire web config is added.
  - Evidence: [driver/lib/firebase_options.dart](driver/lib/firebase_options.dart), [customer/lib/firebase_options.dart](customer/lib/firebase_options.dart)
- **Map API key placeholders**: Android/iOS manifests include `YOUR_API_KEY_HERE` placeholders that must be replaced for runtime map usage.
  - Evidence: [driver/android/app/src/main/AndroidManifest.xml](driver/android/app/src/main/AndroidManifest.xml), [customer/android/app/src/main/AndroidManifest.xml](customer/android/app/src/main/AndroidManifest.xml), [customer/ios/Runner/AppDelegate.swift](customer/ios/Runner/AppDelegate.swift)

## Notes
- Firebase Functions engine is set to Node 20 LTS in [functions/package.json](functions/package.json).
- No build-breaking dependency conflicts were detected in app pubspecs. Assets referenced in pubspecs exist in repo.
