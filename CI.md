# CI

## Triggers
- Pull requests to any branch.

## Jobs
### Flutter - driver
- flutter pub get
- flutter analyze
- flutter test

### Flutter - customer
- flutter pub get
- flutter analyze
- flutter test

### Flutter - admin
- flutter pub get
- flutter analyze
- flutter test (only if admin/test has files)

### Functions
- npm ci
- npm run lint (only if script exists)
- npm run test (only if script exists)

## Caching
- Flutter pub cache via `subosito/flutter-action`.
- npm cache via `actions/setup-node` with `functions/package-lock.json`.

## Fail Fast
- Any failing step stops its job and fails the PR check.
- Jobs run independently; a failure in any job fails the workflow.
