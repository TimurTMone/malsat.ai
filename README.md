# MalSat — Livestock Marketplace for Kyrgyzstan

A mobile-first marketplace for buying and selling livestock (horses, cattle, sheep, Arashan) in Kyrgyzstan. Features phone OTP auth, real-time messaging, AI-powered photo analysis, and a Flutter mobile app.

## Stack

**Backend** (`/src/`)
- Next.js 16 + React 19 + TypeScript
- Prisma 7 + PostgreSQL
- JWT auth with phone OTP
- Claude Vision API for AI photo analysis
- Sharp for server-side image compression

**Mobile app** (`/malsat_app/`)
- Flutter with Riverpod state management
- GoRouter with StatefulShellRoute
- Feature-first clean architecture
- i18n (Kyrgyz + Russian)

## Features

- Phone OTP authentication (JWT access + refresh tokens)
- Listings with filters (category, price, region, breed, gender)
- Favorites (toggle + list)
- Real-time messaging (polling every 3s)
- AI photo analysis (auto-fill listing form from a single photo)
- Image compression pipeline (WebP, full + thumbnail)
- Premium/boost monetization model
- Full i18n support (Kyrgyz/Russian)

## Setup

### Prerequisites

- Node.js 20+
- PostgreSQL 14+ (`brew install postgresql@17 && brew services start postgresql@17`)
- Flutter 3.41+
- An [Anthropic API key](https://console.anthropic.com) (optional, for AI features)

### Backend

```bash
# Install dependencies
npm install

# Create database
createdb malsat

# Configure environment
cp .env.example .env
# Edit .env — set DATABASE_URL, JWT_SECRET, ANTHROPIC_API_KEY

# Run migrations
npx prisma migrate deploy
npx prisma generate

# Seed with real lalafo.kg market data (41 listings)
npm run seed

# Start dev server
npx next dev --port 3003
```

API will be at `http://localhost:3003`.

### Mobile app

```bash
cd malsat_app

# Install Flutter dependencies
flutter pub get

# Configure environment
cp .env.example .env
# Edit .env if your backend runs on a different port

# Run on Chrome (web)
flutter run -d chrome

# Or run on iOS/Android
flutter run
```

## API endpoints

### Auth
- `POST /api/auth/login` — send OTP to phone
- `POST /api/auth/verify` — verify OTP, get JWT tokens
- `POST /api/auth/refresh` — refresh access token

### Listings
- `GET /api/listings` — list with filters + pagination
- `GET /api/listings/[id]` — detail
- `POST /api/listings` — create (auth required)
- `PATCH /api/listings/[id]` — update (owner only)
- `DELETE /api/listings/[id]` — delete (owner only)

### Favorites
- `GET /api/favorites` — list user's favorites
- `POST /api/favorites` — toggle favorite

### Messaging
- `GET /api/conversations` — list user's conversations
- `POST /api/conversations` — create or get existing conversation
- `GET /api/conversations/[id]/messages` — fetch messages (polling supported via `?after=msgId`)
- `POST /api/conversations/[id]/messages` — send message

### Upload + AI
- `POST /api/upload` — upload image (auto-compresses to WebP + thumbnail)
- `POST /api/ai/analyze-photo` — Claude Vision auto-fill from photo
- `POST /api/ai/remove-background` — photo quality analysis + enhancement

### Users
- `GET /api/users/[id]` — public user profile

## Test accounts

The seed creates 8 test users. OTP codes appear in the Next.js server console in dev mode.

```
+996555100100  Айбек Маматов (verified breeder, horses)
+996555200200  Нурлан Токтосунов (verified, cattle)
+996555400400  Гульнара Сыдыкова (verified, Arashan premium)
+996555700700  Эрмек Байышов (verified, Arashan)
# ...through +996555800800
```

## Database schema

See [`prisma/schema.prisma`](prisma/schema.prisma). Core models:
- **User** — phone, name, trust score, verified breeder flag
- **Listing** — category, breed, price, age, weight, gender, premium flag
- **ListingMedia** — photos/videos per listing
- **Favorite, Review, Conversation, Message** — social + messaging

Enums: `AnimalCategory` (HORSE/CATTLE/SHEEP/ARASHAN), `AnimalGender` (MALE/FEMALE), `ListingStatus` (ACTIVE/SOLD/EXPIRED).

## Project structure

```
malsat-ai/
├── src/
│   ├── app/api/          — Next.js API routes
│   ├── lib/              — auth, prisma, anthropic, sms helpers
│   ├── i18n/             — Kyrgyz + Russian dictionaries
│   └── middleware.ts     — CORS + locale routing
├── prisma/
│   ├── schema.prisma     — database schema
│   └── seed.ts           — real lalafo.kg market data (41 listings)
└── malsat_app/
    └── lib/
        ├── core/         — constants, network, storage, router, widgets, i18n
        └── features/
            ├── auth/         — phone OTP login
            ├── home/         — main feed
            ├── search/       — filters + pagination
            ├── listing_detail/ — full detail + shared domain models
            ├── sell/         — create listing + AI auto-fill
            ├── favorites/    — toggle + list
            ├── messages/     — chat list + chat screen
            └── profile/      — user profile + public view
```

## License

Private project. All rights reserved.
