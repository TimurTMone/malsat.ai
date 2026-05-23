// Seeds one curated Bishkek halal butcher partner for the P0 butcher
// service. Idempotent — running it twice does not duplicate rows.
//
//   npx tsx prisma/seed-butcher.ts

import { PrismaClient } from "../src/generated/prisma/client";
import { PrismaPg } from "@prisma/adapter-pg";

const connectionString =
  process.env.DATABASE_URL || "postgresql://localhost:5432/malsat";
const adapter = new PrismaPg(connectionString);
const prisma = new PrismaClient({ adapter });

const PARTNER_PHONE = "+996700101010";
const PARTNER_NAME = "Бишкек Халал Союуш";
const PARTNER_ADDRESS = "Бишкек, Шопоков көчөсү 142";
const PARTNER_REGION_NAME_KY = "Бишкек";

async function main() {
  console.log("🥩 Seeding Bishkek butcher partner…");

  // 1. Region (Bishkek) — try to find, otherwise create.
  let region = await prisma.region.findFirst({
    where: { nameKy: PARTNER_REGION_NAME_KY },
  });
  if (!region) {
    region = await prisma.region.create({
      data: {
        nameKy: PARTNER_REGION_NAME_KY,
        nameRu: "Бишкек",
        type: "OBLAST",
      },
    });
    console.log(`   + Created region: ${region.id}`);
  }

  // 2. Partner User account (idempotent on phone).
  const user = await prisma.user.upsert({
    where: { phone: PARTNER_PHONE },
    update: {
      name: PARTNER_NAME,
      isVerifiedBreeder: true,
      trustScore: 5.0,
    },
    create: {
      phone: PARTNER_PHONE,
      name: PARTNER_NAME,
      isVerifiedBreeder: true,
      trustScore: 5.0,
      regionId: region.id,
      preferredLang: "ky",
      bio: "Бишкектеги халал союш кызматы. Каада-салт менен, кыбылага каратып.",
    },
  });
  console.log(`   ✓ Partner user: ${user.id}`);

  // 3. Synthetic ButcherDrop that every butcher-service order points at.
  // We look up the existing partner first so we can reuse its drop.
  const existingPartner = await prisma.butcherPartner.findUnique({
    where: { userId: user.id },
  });

  let syntheticDropId: string;
  if (existingPartner) {
    syntheticDropId = existingPartner.syntheticDropId;
    console.log(`   = Reusing synthetic drop: ${syntheticDropId}`);
  } else {
    const drop = await prisma.butcherDrop.create({
      data: {
        sellerId: user.id,
        title: "Союуш кызматы — Бишкек",
        description:
          "Халал, кыбылага каратылып, имам менен дуба окулуп союлат. Эвентке жеткирилет.",
        category: "CATTLE",
        totalWeightKg: 999999,
        remainingWeightKg: 999999,
        pricePerKg: 0,
        minOrderKg: 0,
        butcherDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000), // 1y future
        pickupAddress: PARTNER_ADDRESS,
        regionId: region.id,
        village: PARTNER_REGION_NAME_KY,
        deliveryAvailable: true,
        deliveryFee: 800,
        status: "OPEN",
      },
    });
    syntheticDropId = drop.id;
    console.log(`   + Synthetic drop: ${syntheticDropId}`);
  }

  // 4. ButcherPartner row.
  const partner = await prisma.butcherPartner.upsert({
    where: { userId: user.id },
    update: {
      name: PARTNER_NAME,
      regionId: region.id,
      phone: PARTNER_PHONE,
      isActive: true,
      pricePerKgByCategory: JSON.stringify({
        CATTLE: 50,
        SHEEP: 60,
        HORSE: 65,
        ARASHAN: 90,
      }),
      imamFeeKgs: 500,
      deliveryFeeKgs: 800,
    },
    create: {
      userId: user.id,
      syntheticDropId,
      name: PARTNER_NAME,
      description: "Каада-салт менен, кыбылага каратып, имам менен дуба.",
      regionId: region.id,
      phone: PARTNER_PHONE,
      // Per-kg of LIVE animal weight — covers slaughter + butcher +
      // packaging. Delivery + imam fee are charged separately. Numbers
      // are placeholders pending CFO sign-off before launch.
      pricePerKgByCategory: JSON.stringify({
        CATTLE: 50,
        SHEEP: 60,
        HORSE: 65,
        ARASHAN: 90,
      }),
      imamFeeKgs: 500,
      deliveryFeeKgs: 800,
      isActive: true,
    },
  });
  console.log(`   ✓ Butcher partner: ${partner.id}`);
  console.log("✅ Seed complete.");
}

main()
  .catch((err) => {
    console.error("❌ Seed failed:", err);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
