# MalSat — Strategic Plan

*CTO + Bezos-mode analysis. Updated 2026-04-04.*

## Thesis (north star)

MalSat is not a marketplace — it's the **operating system, banking layer, and export arm** for the Central Asian livestock economy. Classifieds is the wedge. Real revenue comes from B2B aggregation, fintech, and halal export.

**Why:** Rural livestock economies (~20M households across Central Asia) have no digital infrastructure. Winner-take-most per country because of data + trust + switching-cost moats compounding.

**Prioritization rule:** When deciding what to build, ask "does this deepen the data moat or open a new revenue layer beyond classifieds?" Features that only improve marketplace UX without feeding future layers (CRM, fintech, B2B, export) are lower priority than ones that unlock the flywheel.

## Market sizing

- **Kyrgyzstan:** ~1.2M livestock households, ~$400M annual trade, <1% digitized today
- **Central Asia TAM** (KG + KZ + UZ + TJ + TM + MN): ~$12B annual livestock trade, ~20M farmer households
- **Halal global supply chain:** $2.3T by 2030 (export angle)
- **Eid al-Adha in KG alone:** 400K sheep slaughtered in ~2 weeks = $40M

## The flywheel

```
More farmers list (free)
        ↓
Richer price + genetic data on every animal
        ↓
AI pricing + fraud detection + weight estimation
        ↓
Banks trust data → livestock-backed loans + insurance priced accurately
        ↓
Farmers get credit they never had → buy more → list more
        ↓
B2B + export buyers trust supply → bigger contracts → higher LTV
        ↓
(data moat deepens — loop reinforces)
```

## Revenue stack — 8 layers (24-month ARR targets)

| Layer | Product | Model | ARR target |
|---|---|---|---|
| **L1 Wedge** | Marketplace, Boost, Verified Breeder | Per-listing + sub | $120K |
| **L2 SaaS core** | MalSat PRO (herd CRM, vet cal, breeding) | $12-35/mo | $600K |
| **L3 Labor & Infra** | Shepherd Finder, Pasture marketplace | 5% take rate | $250K |
| **L4 B2B Wholesale** | Supermarket / restaurant / caterer aggregation | 3-8% commission | $1.8M |
| **L5 FinTech** | Livestock-backed loans, insurance broker | Origination + interest share | $900K |
| **L6 Data** | Pricing APIs, market reports | $10-100K/yr enterprise | $300K |
| **L7 Export** | MalSat Global — halal export brokerage (KSA/UAE/Iran/CN) | 3-5% on deals | $2M+ |
| **L8 AdTech** | Sponsored breeds, feed brands | CPM/CPC | $200K |

- **24-month target:** ~$6M ARR ($500K MRR)
- **36-month target:** $15M ARR ($1.25M MRR)

**"Millions monthly" comes from L4 + L5 + L7 — not the marketplace.** Marketplace owns the supply side that makes everything else possible.

## Moats (defensibility)

1. **Data** — every listing + photo + closed deal trains a proprietary Central Asia livestock vision + pricing model. Replication requires 5+ years of GMV.
2. **Network effects** — liquidity begets liquidity.
3. **Switching cost** — 2 years of herd history in MalSat PRO = catastrophic to leave.
4. **Regulatory** — become the de-facto national livestock registry partner per country.
5. **Offline-first tech** — rural 2G/3G works only with deliberate engineering investment.
6. **Financial moat (long-term)** — credit scoring from herd data is unreplicable.

## AI leverage (the differentiator)

- **Computer vision** — photo → weight / age / breed / health score / body condition score; fraud detection via reverse-image search; background removal. Half-built at `/api/ai/*`.
- **Price intelligence** — "Fair price" suggestion on every listing, regional + seasonal alerts.
- **Kyrgyz + Russian voice assistant** — critical for semi-literate rural farmers, voice listing creation.
- **Predictive** — demand forecasting for B2B, breeding matching, disease outbreak detection.
- **Data moat** — every photo trains the proprietary model; banks MUST license our API for collateral valuation after M18.

## Tech architecture additions (post-TestFlight)

| Need | Choice | Timing |
|---|---|---|
| Event bus | Inngest / Upstash Redis | When async workflows appear (M6+) |
| Vector DB | pgvector → Pinecone | For image similarity + fraud (M9+) |
| Object storage | Vercel Blob → Cloudflare R2 | At 10TB (zero egress fees) |
| ML serving | Replicate / Modal | Until $100K MRR, then self-host GPUs |
| Data warehouse | BigQuery / ClickHouse | At 1M listings (for L6 products) |
| i18n | ky, ru, kk, uz, mn, tr, ar | 6 languages by M18 |

## Expansion sequence

Y1-2: Dominate KG → Y2 enter KZ → Y3 UZ + TJ + MN → Y5+ Turkey / Iran / MENA pastoral → Y7+ East Africa pastoralist corridor.

## Fun tech (brand + culture)

Livestock Pokedex (swipeable feed), livestreams from pastures, gamified verification tiers (Bronze → Platinum Breeder), farmer leaderboards, voice-first for elders, AI sheep passports (PDF + QR + provenance), open-source genetics registry, Bishkek/Almaty agri-hackathons.

## Funding plan

| Round | When | Amount | Use | MRR gate |
|---|---|---|---|---|
| Pre-seed | Now → M3 | $500K-$1M | TestFlight launch, V1 monetization, data foundations | $5K |
| Seed | M9-12 | $2-4M | KZ launch, B2B team | $50K |
| Series A | M12-15 | $5-10M | Multi-country, fintech, ML team | $300K |
| Series B | M24-30 | $25-50M | Export infra + cold chain | $3M |
| Series C + banking license | Y3+ | $80-150M | Direct lending, Eurasia + Africa | $10M+ |

## Bezos working-backwards press release — target M24

> **MalSat, Central Asia's Livestock Operating System, Surpasses 250,000 Farmers Across 4 Countries and Originates $80M in Livestock-Backed Loans.**
>
> BISHKEK — MalSat announced today that its platform has enabled more than $400M in livestock trade over the past 12 months. Farmers on MalSat now have access to the region's first livestock-backed credit products, AI-driven pricing that has increased median sale prices by 23%, and direct export routes to halal markets in the Gulf. MalSat's computer vision model has analyzed 18M livestock photos and is licensed by three Central Asian banks for collateral valuation.

**Every sprint should answer: "does this get us closer to the press release?"**
