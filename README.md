# MalSat — Livestock & Meat Marketplace for Kyrgyzstan

> Farm-to-table livestock and meat marketplace. Mobile-first (Flutter) app with Next.js backend.
> **Status:** v1.4.0 on TestFlight (build 1200). Not yet submitted to App Store / Google Play.

---

## What This Does

A two-sided marketplace where:

- **Buyers** browse meat drops (sold by kg), live auctions, and livestock listings, then place orders / bids
- **Sellers** create meat drops, livestock listings, manage their herd, and fulfill orders with photo-verified delivery stages
- **Bazaars** can run live auctions for livestock straight from the marketplace floor

Three core surfaces:

1. **Эт Базар** (Meat Drops) — sellers butcher and sell fresh meat by kg (5kg, 10kg, custom slider). 7-stage fulfillment with photo proof at each stage. Manual QR-code payment (buyer uploads receipt).
2. **Мал Базар** (Livestock Listings) — classic listing-style marketplace with photo, price, breed, age, weight. Horse subcategories: meat horse vs Көк Бөрү (sport horse).
3. **Аукцион** (Live Auctions) — real bazaar listings with timer, current-bid hero, one-tap bidding.

---

## Tech Stack

### Backend (`/src/`)
- **Next.js 16** App Router, React 19, TypeScript
- **Prisma 7** + PostgreSQL (production on Vercel, local dev on `localhost:3003`)
- **JWT auth** — phone OTP (5 min expiry)
- **Demo auth bypass** — magic OTP code `000000` for App Store reviewers
- **Claude Vision** for AI livestock photo analysis (auto-fill listing form from photo)
- **Sharp** for server-side image compression
- **Demo data fallback** — when DB is empty, API serves rich demo data from `src/lib/demo-*.ts`

### Mobile App (`/malsat_app/`)
- **Flutter 3.41.5** (stable channel)
- **Riverpod** — state management
- **GoRouter** — `StatefulShellRoute` for tab persistence
- **Dio** — HTTP, with auth interceptor (auto-refreshes 401s)
- **flutter_secure_storage** — token storage
- **gal** — save QR code to Photos
- **image_picker** — camera + photo library
- **i18n** — Kyrgyz (default) + Russian, JSON dictionaries in `lib/core/i18n/dictionaries/`
- **Feature-first architecture** — every feature has `data/`, `domain/`, `presentation/{screens,providers,widgets}/`

### iOS / Android
- **iOS** — Bundle: `com.malsat.malsatApp`, Team: PJPHU42VG4. Fastlane configured (env-vars only — no hardcoded secrets).
- **Android** — Package: `com.malsat.malsat_app`. Release signing configured with keystore at `~/malsat-release.jks`. Min SDK 24, target SDK 36.

---

## Repository Layout

```
malsat-ai/
├── src/                          # Next.js backend
│   ├── app/
│   │   ├── api/                  # All HTTP routes
│   │   │   ├── auth/             #   login, verify, refresh
│   │   │   ├── listings/         #   livestock listings CRUD
│   │   │   ├── drops/            #   meat drops CRUD + ordering
│   │   │   ├── auctions/         #   auctions + bidding (DEMO ONLY, no DB)
│   │   │   ├── orders/           #   order tracking
│   │   │   ├── herd/             #   livestock CRM
│   │   │   ├── ai/               #   Claude vision
│   │   │   └── upload/           #   media uploads
│   │   ├── [locale]/             # Web pages (mostly placeholder)
│   │   ├── privacy/              # Privacy Policy (App Store requirement)
│   │   └── terms/                # Terms of Service
│   ├── lib/
│   │   ├── prisma.ts             # Prisma client
│   │   ├── auth.ts               # JWT signing + middleware
│   │   ├── sms.ts                # OTP generation + SMS sending
│   │   ├── demo-listings.ts      # 12 demo livestock listings
│   │   ├── demo-drops.ts         # 8 demo meat drops
│   │   ├── demo-auctions.ts      # 6 demo auctions
│   │   └── demo-herd.ts          # Demo herd animals
│   └── prisma/schema.prisma      # Full data model
│
├── malsat_app/                   # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app.dart
│   │   ├── core/
│   │   │   ├── constants/        # colors, theme, enums, API endpoints
│   │   │   ├── network/          # Dio client + auth interceptor
│   │   │   ├── storage/          # secure token storage
│   │   │   ├── router/           # GoRouter config
│   │   │   ├── i18n/             # localization
│   │   │   └── widgets/          # shared widgets (ListingCard, BottomNavBar, …)
│   │   └── features/
│   │       ├── auth/             # phone OTP login + verify
│   │       ├── home/             # Livestock listings (Мал Базар)
│   │       ├── drops/            # Meat drops (Эт Базар) — full ordering flow
│   │       ├── auctions/         # Auctions tab + detail + bidding
│   │       ├── sell/             # Create listing form (with AI auto-fill)
│   │       ├── search/           # Filter/search listings
│   │       ├── messages/         # Chat (basic)
│   │       ├── profile/          # User profile + Seller Dashboard
│   │       ├── herd/             # Livestock CRM (accessible at /herd)
│   │       ├── listing_detail/   # Livestock listing detail
│   │       └── favorites/        # Favorites
│   ├── ios/
│   │   ├── fastlane/Fastfile     # `fastlane beta` — build + upload to TestFlight
│   │   └── ExportOptions.plist
│   └── android/
│       ├── app/build.gradle.kts  # Release signing wired up via key.properties
│       └── key.properties        # NOT in git — passwords for keystore
│
├── LAUNCH_CHECKLIST.md           # Master launch task list
├── STORE_METADATA.md             # App Store + Play Store copy (RU + KY)
└── README.md                     # This file
```

---

## ✅ What's Done

### Product features
- [x] **Phone OTP auth** with 5-min expiry, JWT access + refresh tokens
- [x] **Demo login** — "Демо режим — заматта кирүү" button + magic OTP `000000`
- [x] **Meat drops (Эт Базар)** — create, list, detail, place order with weight slider, 7-stage fulfillment with stage photos
- [x] **Order payment** — seller QR code displayed, **Save QR to Photos** button, buyer uploads receipt screenshot
- [x] **Livestock listings (Мал Базар)** — full CRUD + AI auto-fill from photo (Claude Vision)
- [x] **Horse subcategories** — Эт жылкы (meat) vs Көк бөрү (sport) with badge differentiation
- [x] **Auctions (Аукцион)** — list, detail, one-tap bidding, ending-soon urgency, watcher count
- [x] **Seller Dashboard** on profile — Create Drop, Incoming Orders, Payment QR Setup
- [x] **Herd management (CRM)** — track animals, ages, weights, caretakers (route only, not in bottom nav)
- [x] **i18n** — Kyrgyz + Russian, language toggle in profile

### Demo data (when DB is empty, API serves these)
- [x] 12 livestock listings with real Unsplash photos
- [x] 8 meat drops with real Unsplash meat-cut photos
- [x] 6 live auctions across Kyrgyz bazaars (Ат-Башы, Кара-Балта, Ош, Каракол, Талас, Жалал-Абад)

### Infrastructure / Launch prep
- [x] **iOS release build** signed and uploadable to TestFlight via Fastlane
- [x] **TestFlight build 1200** uploaded and processing
- [x] **Android release keystore** generated (`~/malsat-release.jks`), `key.properties` configured
- [x] **Android AAB** built (`build/app/outputs/bundle/release/app-release.aab`, 44.8 MB)
- [x] **Privacy Policy** at `malsat-ai.vercel.app/privacy`
- [x] **Terms of Service** at `malsat-ai.vercel.app/terms`
- [x] **Bottom nav order**: Эт базар → Мал базар → Sell → Аукцион → Profile (meat-first)
- [x] **Security cleanup** — DIO logs only in debug mode, Fastlane uses env vars, `.env` gitignored
- [x] **Zero `flutter analyze` warnings/errors**
- [x] App icons set (iOS only — Android uses default Flutter icon)
- [x] Web manifest + index.html updated

### Documentation
- [x] [LAUNCH_CHECKLIST.md](LAUNCH_CHECKLIST.md) — master pre-launch task list
- [x] [STORE_METADATA.md](STORE_METADATA.md) — copy-paste ready app descriptions, keywords, data safety answers (Russian + Kyrgyz)

---

## ❌ What's Not Done (Hand-off List)

### Blockers — must do before App Store / Play Store submission
1. **Create the app in App Store Connect** (https://appstoreconnect.apple.com)
   - App name: MalSat, Bundle: `com.malsat.malsatApp`, Primary language: Russian
   - Once created, the existing TestFlight upload (build 1200) will appear under the app
2. **Create the app in Google Play Console** (https://play.google.com/console)
   - Upload `malsat_app/build/app/outputs/bundle/release/app-release.aab`
3. **Take screenshots** at required sizes — see `STORE_METADATA.md` for the 8 suggested screens
   - iPhone 6.7" (1290×2796), iPhone 6.5" (1284×2778)
   - Android phone (1080×1920+), feature graphic (1024×500)
4. **Fill age rating questionnaire** in both consoles → 4+ / Everyone
5. **Fill data safety form** in Google Play → answers prepared in `STORE_METADATA.md`
6. **Set up support email** → e.g. `support@malsat.kg` (currently referenced in privacy/terms but no inbox exists)
7. **Test full flow on real device** — auth → browse → order meat → upload payment receipt → seller confirms

### Features that are partial / stubbed
- **AI photo analysis** — works for livestock listings, no implementation for meat drops or auctions
- **Messaging (chat)** — basic API + screen exist but not heavily tested. No push notifications.
- **Auctions are demo-only** — no Prisma model yet. Bids return success but aren't persisted. Need to:
  - Add `Auction` and `Bid` models to `prisma/schema.prisma`
  - Wire `/api/auctions/*` routes to use Prisma when DB has auctions
  - Add real-time bid updates (currently the UI doesn't auto-refresh — pull-to-refresh required)
- **Auction creation UI** — there's no screen for sellers to create auctions yet (only browse/bid)
- **Push notifications** — not configured (no Firebase, no APNs setup beyond what TestFlight needs)
- **Real payment processing** — manual QR + screenshot only. No Stripe / Demir Bank / etc.
- **Web/mobile hub features** — `Hub` and `Token` Prisma models exist with API routes but no UI
- **Reviews** — Prisma model exists, no UI
- **Search filters** — basic category filter works; price range, region, breed filter wiring incomplete

### Tech debt
- **Fastlane upload lane bug** — Flutter 3.41.5 crashes on `flutter build ipa` when `build/ios/ipa/` doesn't exist after `flutter clean`. Workaround in our build script: `mkdir -p build/ios/ipa` before running, then export via `xcodebuild -exportArchive` directly. See git log for examples.
- **Build number drift** — App Store Connect rejected several version numbers as "already used" during the launch session. Currently at `1.4.0+1200`. Always bump build number on each TestFlight upload.
- **Missing dSYM upload** — `ExportOptions.plist` has `uploadSymbols=false` (workaround for an Xcode dSYM mismatch). Means crash reports won't be symbolicated until this is fixed.
- **Demo data is hardcoded** — once real users start posting, the fallback demo data should be removed (or hidden behind a feature flag)
- **40 `flutter pub outdated` packages** — none are urgent, but worth a planned upgrade pass
- **Backend `.env`** — points to `localhost:3003` for local dev. Production uses `--dart-define=API_BASE_URL=https://malsat-ai.vercel.app` at build time
- **Crash reporting** — no Crashlytics / Sentry setup
- **Tests** — only the boilerplate widget test exists. No integration tests.

### Backend / DB
- Database currently runs on Vercel (free tier or paid?) — verify. Free Postgres providers can sleep / wipe data
- Add automatic backups
- Need to actually populate DB with seed data (currently relies on demo data fallback)
- Webhook for SMS provider — currently using `console.log` in development mode. Production SMS provider not configured.

---

## Local Development

### Backend
```bash
# /Users/timurmone/Desktop/AppAltai/malsat-ai
npm install
npx prisma migrate dev
npm run dev
# → runs on http://localhost:3003
```

### Flutter app
```bash
# /Users/timurmone/Desktop/AppAltai/malsat-ai/malsat_app
flutter pub get
flutter run -d <device-id>
# Local dev hits .env API_BASE_URL=http://localhost:3003
# Pass --dart-define=API_BASE_URL=https://malsat-ai.vercel.app to hit production
```

### Build for TestFlight
```bash
cd malsat_app

# 1. Bump version in pubspec.yaml (always bump build number)
# 2. Clean build
flutter clean && flutter pub get

# 3. Build IPA
flutter build ipa --release \
  --dart-define=API_BASE_URL=https://malsat-ai.vercel.app \
  --export-options-plist=ios/ExportOptions.plist
# (If this crashes with PathNotFoundException, the archive succeeded —
#  the IPA export step has a known Flutter 3.41.5 bug after `flutter clean`)

# 4. Manual export + upload (workaround for the Flutter bug)
mkdir -p build/ios/ipa
xcodebuild -exportArchive \
  -archivePath build/ios/archive/Runner.xcarchive \
  -exportPath build/ios/ipa \
  -exportOptionsPlist ios/ExportOptions.plist
```

### Build Android AAB
```bash
cd malsat_app
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://malsat-ai.vercel.app
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## Demo Login Credentials

For App Store reviewers and demo purposes:
- **Phone:** `+996 555 000 000`
- **OTP code:** `000000`
- Or just tap **"Демо режим — заматта кирүү"** on the login screen — auto-logs in.

---

## Important Files & Conventions

- **API endpoints** — defined in `malsat_app/lib/core/constants/api_endpoints.dart` (single source of truth)
- **App colors** — `malsat_app/lib/core/constants/app_colors.dart`
- **i18n strings** — `malsat_app/lib/core/i18n/dictionaries/{ky,ru}.json`
- **Demo data** — `src/lib/demo-*.ts` (always include real-looking content; falls back when DB is empty)
- **Backend response format** — every API uses `ok()` / `errorResponse()` from `src/lib/response.ts`
- **Auth requirement** — `requireAuth(req)` from `src/lib/auth.ts` validates JWT and throws if missing

---

## Repository

- **GitHub:** https://github.com/TimurTMone/malsat.ai
- **Backend:** https://malsat-ai.vercel.app (Vercel)
- **Privacy:** https://malsat-ai.vercel.app/privacy
- **Terms:** https://malsat-ai.vercel.app/terms

---

## Contact

This project is owned by **Timur Mone** (timur.mone@gmail.com).

For continuation of work, the highest-leverage starting points are:
1. Knock out the 7 launch blockers above (mostly admin work in App Store Connect / Play Console)
2. Migrate `Auction` and `Bid` to real Prisma models (currently hardcoded demo)
3. Build the auction creation UI for sellers
4. Wire up real SMS provider for production OTPs
5. Add crash reporting (Sentry recommended)

See [LAUNCH_CHECKLIST.md](LAUNCH_CHECKLIST.md) for the granular pre-launch checklist.
