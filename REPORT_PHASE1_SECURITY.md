# Phase 1 – Security Remediation Report

## 1) Secrets / Private Keys Found (paths)
- Service account JSON (contained private_key): [Database/config.json](Database/config.json) (removed).
- Firestore export data dump (PII risk): [Database/database.json](Database/database.json) (removed).
- Archive of database exports: [Database.zip](Database.zip) (removed).
- Firebase client config keys (public API keys, still present by design):
  - [driver/lib/firebase_options.dart](driver/lib/firebase_options.dart)
  - [customer/lib/firebase_options.dart](customer/lib/firebase_options.dart)
  - [admin/lib/firebase_options.dart](admin/lib/firebase_options.dart)
  - [admin/firebase.js](admin/firebase.js)

## 2) Secret Removal & Templates
- Added template for service account: [Database/config.example.json](Database/config.example.json).
- Added template for sample data: [Database/database.example.json](Database/database.example.json).
- Updated tooling to load service account from `FIREBASE_SERVICE_ACCOUNT` env var or local file:
  - [Database/import.js](Database/import.js)
  - [Database/export.js](Database/export.js)

## 3) Firestore Rules (Least‑Privilege)
- Deployed rules are now aligned via [firebase.json](firebase.json) → [firestore_index/firestore.rules](firestore_index/firestore.rules).
- Open rules in admin were replaced with least‑privilege rules:
  - [admin/firestore.rules](admin/firestore.rules)

## 4) App Check Notes
- Documented steps (no code changes) in [SECURITY.md](SECURITY.md).

## 5) Files Added
- [SECURITY.md](SECURITY.md)

## 6) Files Removed
- [Database/config.json](Database/config.json)
- [Database/database.json](Database/database.json)
- [Database.zip](Database.zip)

## 7) Required Local Setup
- Export/import tooling now expects:
  - `FIREBASE_SERVICE_ACCOUNT=/absolute/path/to/service-account.json`
  - Or copy [Database/config.example.json](Database/config.example.json) → `Database/config.json` locally (do not commit).
