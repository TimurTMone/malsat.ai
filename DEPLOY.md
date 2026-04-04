# Deploy to Vercel

## Prerequisites

1. A hosted PostgreSQL database (Vercel Postgres, Supabase, Neon, or Railway)
2. An Anthropic API key (for AI features)

## Steps

### 1. Create the database

Easiest option — **Vercel Postgres** (integrated, one-click):
1. Go to your Vercel project → Storage → Create Database → Postgres
2. Copy the `DATABASE_URL` it provides

Alternative — **Supabase** (free tier, 500MB):
1. Create project at supabase.com
2. Settings → Database → Connection String (use the "Transaction" mode pooler URL)

### 2. Import to Vercel

```bash
# Push your changes to GitHub first
git push

# Then on vercel.com:
# 1. Import Git Repository → select TimurTMone/malsat.ai
# 2. Framework Preset: Next.js (auto-detected)
# 3. Root Directory: ./ (leave default)
# 4. Build Command: next build (auto-detected)
```

### 3. Add environment variables

In Vercel project settings → Environment Variables:

| Variable | Required | Value |
|----------|----------|-------|
| `DATABASE_URL` | ✅ Yes | Your Postgres connection string |
| `JWT_SECRET` | ✅ Yes | Generate with `openssl rand -hex 32` |
| `ANTHROPIC_API_KEY` | Optional | From console.anthropic.com (for AI features) |
| `NODE_ENV` | Optional | `production` (Vercel sets this automatically) |

### 4. Run migrations after first deploy

After Vercel builds successfully, run migrations against your production DB:

```bash
# Locally, with the production DATABASE_URL in .env.production:
DATABASE_URL="<production-url>" npx prisma migrate deploy

# Seed with market data (optional):
DATABASE_URL="<production-url>" npm run seed
```

Or use Vercel's build command hook in `package.json`:
```json
"scripts": {
  "build": "prisma generate && prisma migrate deploy && next build"
}
```

### 5. Update the Flutter app

Once deployed, update the Flutter `.env`:
```
API_BASE_URL=https://your-project.vercel.app
```

## Important gotchas

- **Image uploads**: The current `/api/upload` route saves to `public/uploads/` on disk. This **won't work on Vercel** (serverless functions have no persistent disk). You need to swap to cloud storage (Vercel Blob, AWS S3, or Cloudinary).
- **Sharp on Vercel**: Sharp is supported but requires `sharp` to be in `dependencies` (not `devDependencies`) — already correct.
- **Prisma binaries**: The build hook ensures Prisma client is generated with the correct Linux binaries.
- **CORS**: Already configured in `next.config.ts` + `middleware.ts` to allow all origins. Restrict in production if needed.

## Blob storage migration (required before real use)

Add Vercel Blob:
```bash
npm install @vercel/blob
```

Then replace the file-writing logic in `src/app/api/upload/route.ts` with:
```typescript
import { put } from '@vercel/blob';
const { url } = await put(filename, buffer, { access: 'public' });
```

Environment variable `BLOB_READ_WRITE_TOKEN` is auto-injected when you add Vercel Blob storage.
