# Vybgov1
Ride Hailing app

## Local Development

### Prerequisites
- Flutter SDK installed and on PATH
- Node.js 18+ (for Firebase Functions tooling)

### Run apps

From repo root:

- Driver app:
	- `npm run driver:run`
- Customer app:
	- `npm run customer:run`
- Admin app (web):
	- `npm run admin:run`

### Functions (lint)

From repo root:

- `npm run functions:ci`

> Note: No Functions test script was found in [functions/package.json](functions/package.json). If you add tests later, update the script accordingly.
