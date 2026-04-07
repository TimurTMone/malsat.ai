import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth } from "@/lib/auth";
import { ok, handleError } from "@/lib/response";

// GET — my token portfolio (like a stock portfolio)
export async function GET(req: NextRequest) {
  try {
    const auth = requireAuth(req);

    const holdings = await prisma.tokenHolder.findMany({
      where: { userId: auth.userId },
      include: {
        animal: {
          include: {
            farmer: {
              select: {
                id: true,
                name: true,
                avatarUrl: true,
                trustScore: true,
              },
            },
            media: { take: 1 },
          },
        },
      },
      orderBy: { updatedAt: "desc" },
    });

    let totalInvested = 0;
    let totalCurrentValue = 0;
    let totalMeatKg = 0;

    const portfolio = holdings.map((h) => {
      const investedValue = h.tokens * h.animal.initialPriceKgs;
      const currentValue = h.tokens * h.animal.currentPriceKgs;
      const meatKg = h.tokens * h.animal.meatPerTokenKg;
      const gainPercent = investedValue > 0
        ? Math.round(((currentValue - investedValue) / investedValue) * 100)
        : 0;

      totalInvested += investedValue;
      totalCurrentValue += currentValue;
      totalMeatKg += meatKg;

      return {
        id: h.id,
        tokens: h.tokens,
        totalTokens: h.animal.totalTokens,
        ownershipPercent: Math.round((h.tokens / h.animal.totalTokens) * 100),
        investedValue,
        currentValue,
        gainPercent,
        meatKg: Math.round(meatKg * 10) / 10,
        animal: {
          id: h.animal.id,
          name: h.animal.name,
          category: h.animal.category,
          breed: h.animal.breed,
          currentWeightKg: h.animal.currentWeightKg,
          status: h.animal.status,
          butcherDate: h.animal.butcherDate,
          photoUrl: h.animal.photoUrl,
          currentPriceKgs: h.animal.currentPriceKgs,
          initialPriceKgs: h.animal.initialPriceKgs,
          farmer: h.animal.farmer,
          media: h.animal.media,
        },
      };
    });

    return ok({
      portfolio,
      summary: {
        totalAnimals: holdings.length,
        totalTokens: holdings.reduce((s, h) => s + h.tokens, 0),
        totalInvested,
        totalCurrentValue,
        totalGainPercent: totalInvested > 0
          ? Math.round(
              ((totalCurrentValue - totalInvested) / totalInvested) * 100
            )
          : 0,
        totalMeatKg: Math.round(totalMeatKg * 10) / 10,
      },
    });
  } catch (error) {
    return handleError(error);
  }
}
