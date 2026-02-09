# Test Plan

## Scope
Minimal high-value test coverage across customer, driver, and admin apps:
- Auth validation unit tests
- Initial routing widget test (logged in vs logged out)
- Smoke widget tests for login views

## Tests Added
### Customer
- auth validation unit test
  - Validates `Constant.validateEmail` and `Constant.validateRequired`
- login view smoke widget test
  - Verifies basic login UI renders without Firebase calls

### Driver
- auth validation unit test
  - Validates `Constant.validateEmail` and `Constant.validateRequired`
- login view smoke widget test
  - Verifies basic login UI renders without Firebase calls

### Admin
- auth validation unit test
  - Validates `Constant.validateEmail` and `Constant.validatePassword`
- initial routing widget test
  - Uses `SplashScreenController.routeForLoginState` to verify routing logic

## Execution
Run from each app folder:
- flutter test

CI suggestion:
- customer: `flutter test`
- driver: `flutter test`
- admin: `flutter test`

## Notes
- Firebase calls are not invoked by these tests.
- Widget tests use GetX and Provider as in production views.
