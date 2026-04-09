# MalSat Launch Checklist — App Store & Google Play

> Reference this file whenever resuming launch prep work.
> Last updated: 2026-04-09

---

## Fixes Already Applied

- [x] Deleted flutter log files (flutter_01/02/03.log)
- [x] Added .env, build logs, fastlane artifacts, key.properties to .gitignore
- [x] DIO logging now debug-only (assert() guard)
- [x] Android app label: malsat_app → MalSat
- [x] Removed hardcoded API keys from Fastlane (env vars only)
- [x] Web manifest: name, description, theme color updated
- [x] Web index.html: title, description, app title updated
- [x] Android release signing configured (key.properties + build.gradle.kts)
- [x] Target API level verified: targetSdk=36 (exceeds Google Play requirement of 34)
- [x] Privacy Policy page created at /privacy
- [x] Terms of Service page created at /terms
- [x] Store metadata written to STORE_METADATA.md (descriptions, keywords, data safety)

## Meat by Weight — Already Implemented

Sellers set: totalWeightKg, pricePerKg, minOrderKg, maxOrderKg, portionPresets [5,10,15].
Buyers: preset buttons or custom slider. Inventory auto-decrements, auto SOLD_OUT.

---

## Apple App Store (iOS)

- [ ] **1. App Store Connect setup** — create app at appstoreconnect.apple.com
  - App name: MalSat
  - Bundle ID: com.malsat.malsatApp
  - Primary language: Russian
  - Category: Shopping / Lifestyle

- [ ] **2. App Store screenshots** (required sizes)
  - iPhone 6.7" (1290×2796) — iPhone 15 Pro Max
  - iPhone 6.5" (1284×2778) — iPhone 14 Plus
  - iPad 12.9" (2048×2732) — if supporting iPad
  - Min 3, max 10 per size
  - See STORE_METADATA.md for suggested screens to capture

- [x] **3. App Store metadata** — DONE, see STORE_METADATA.md
  - Description, promotional text, keywords (Russian + Kyrgyz)
  - Copy-paste into App Store Connect

- [ ] **4. Age rating** — questionnaire (no violence/gambling = 4+)

- [x] **5. Export compliance** — ITSAppUsesNonExemptEncryption = false (already set)

- [ ] **6. Fastlane env vars** — before deploying:
  ```bash
  export ASC_KEY_ID="Z7MGS5ZUZ5"
  export ASC_ISSUER_ID="bba04448-ff86-400c-8a1c-9828ce554f07"
  export ASC_KEY_PATH="~/.appstoreconnect/private_keys/AuthKey_Z7MGS5ZUZ5.p8"
  ```

- [ ] **7. Build & submit** — `cd malsat_app/ios && fastlane beta`, submit in App Store Connect

---

## Google Play Store (Android)

- [ ] **8. Google Play Console setup** — create app at play.google.com/console
  - App name: MalSat
  - Default language: Russian
  - Category: Shopping

- [ ] **9. Generate Android keystore** — run this command, then update passwords in `android/key.properties`:
  ```bash
  keytool -genkey -v -keystore ~/malsat-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias malsat
  ```
  Then edit `malsat_app/android/key.properties` with real passwords (build.gradle.kts already configured)

- [ ] **10. Play Store screenshots**
  - Phone: min 1080×1920, up to 8
  - Feature graphic: 1024×500 (required)
  - App icon: 512×512 hi-res

- [x] **11. Play Store listing** — DONE, see STORE_METADATA.md
  - Short desc (80 chars) + full desc, Russian + Kyrgyz

- [ ] **12. Content rating** — IARC questionnaire

- [x] **13. Data safety form** — answers ready in STORE_METADATA.md

- [ ] **14. Build AAB**
  ```bash
  cd malsat_app && flutter build appbundle --release --dart-define=API_BASE_URL=https://malsat-ai.vercel.app
  ```
  Upload: build/app/outputs/bundle/release/app-release.aab

- [x] **15. Target API level** — targetSdk=36, compileSdk=36, minSdk=24 (Flutter 3.41.5 defaults)

---

## Both Platforms

- [x] **16. Privacy Policy page** — created at src/app/privacy/page.tsx → malsat-ai.vercel.app/privacy
- [x] **17. Terms of Service** — created at src/app/terms/page.tsx → malsat-ai.vercel.app/terms
- [ ] **18. Support email** — set up support@malsat.kg (or use a Gmail as temporary)
- [ ] **19. Test on real devices** — full flows: auth → browse → order meat → payment → seller confirm
- [ ] **20. Backend stability** — ensure malsat-ai.vercel.app is on a paid Vercel plan
- [ ] **21. Database backups** — enable on DB provider
- [ ] **22. Crash reporting** — consider Firebase Crashlytics or Sentry before launch

---

## Remaining YOU tasks (can't be done by code)

1. **Screenshots** — run app on simulator/device, take screenshots at required sizes
2. **Generate keystore** — run the keytool command above, set real passwords
3. **Create App Store Connect app** — log into appstoreconnect.apple.com
4. **Create Google Play Console app** — log into play.google.com/console
5. **Fill age rating questionnaires** — in both consoles
6. **Set up support email** — support@malsat.kg or alternative
7. **Deploy backend** — push to main so /privacy and /terms pages go live
8. **Test full flows** — auth, browse, order, payment, seller side
9. **Submit for review** — both stores

---

## Key File Paths

- iOS Fastfile: malsat_app/ios/fastlane/Fastfile
- Android build: malsat_app/android/app/build.gradle.kts
- Android key config: malsat_app/android/key.properties
- Android manifest: malsat_app/android/app/src/main/AndroidManifest.xml
- DIO client: malsat_app/lib/core/network/dio_client.dart
- Pubspec: malsat_app/pubspec.yaml
- App router: malsat_app/lib/core/router/app_router.dart
- Drops feature: malsat_app/lib/features/drops/
- Backend API: src/app/api/
- Privacy Policy: src/app/privacy/page.tsx
- Terms of Service: src/app/terms/page.tsx
- Store metadata: STORE_METADATA.md
