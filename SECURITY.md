# Security

## Threat Summary
- **Credential leakage**: Firebase service account keys and data exports must never be committed. (See [Database/config.example.json](Database/config.example.json) for template.)
- **Over‑permissive Firestore rules**: Open rules lead to data exfiltration and unauthorized writes. Rules are now least‑privilege. See [firestore_index/firestore.rules](firestore_index/firestore.rules).
- **Client‑side secrets**: Payment provider secrets must be stored server‑side and exposed only via ephemeral tokens or Cloud Functions. References exist in app code but actual secrets must not be hardcoded.

## Secrets Handling
- **Do not commit** service account JSON or exported database dumps.
- **Use environment variables** or secure secret storage for local tooling:
  - `FIREBASE_SERVICE_ACCOUNT=/absolute/path/to/service-account.json`
  - Tools: [Database/import.js](Database/import.js), [Database/export.js](Database/export.js)
- **Template**: Copy [Database/config.example.json](Database/config.example.json) to `Database/config.json` locally if you cannot use environment variables.

## Key Rotation Checklist
1. **Revoke compromised keys** in Google Cloud Console → IAM & Admin → Service Accounts.
2. **Create new service account key**, store in a secure vault.
3. **Update local secrets** using `FIREBASE_SERVICE_ACCOUNT` env var.
4. **Rotate Firebase Web API keys** if necessary (low risk but recommended after exposure).
5. **Audit Firestore access logs** for anomalous activity.

## Data Export Policy
- **No production data exports** in the repo.
- Store exports in encrypted storage with strict access control.
- Use sanitized sample data files only (example: [Database/database.example.json](Database/database.example.json)).

## Firebase App Check (recommended)
> Not implemented in code here. Follow steps below when ready.

**Android**
1. Firebase Console → App Check → Register Android app.
2. Choose a provider (Play Integrity recommended).
3. Add dependencies and initialize App Check in app startup.

**iOS**
1. Firebase Console → App Check → Register iOS app.
2. Choose a provider (DeviceCheck/App Attest).
3. Add App Check SDK and initialize during app startup.

**Web**
1. Firebase Console → App Check → Register Web app.
2. Choose reCAPTCHA v3/Enterprise.
3. Add App Check SDK and initialize in web bootstrap.

**Enforcement**
- Enable **monitoring mode** first, then enforce per‑service (Firestore/Storage/Functions) once verified.
