import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { ok, errorResponse, handleError } from "@/lib/response";

type Ctx = { params: Promise<{ id: string }> };

// GET — animal detail with token info
export async function GET(req: NextRequest, ctx: Ctx) {
  try {
    const { id } = await ctx.params;

    const animal = await prisma.livestockAnimal.findUnique({
      where: { id },
      include: {
        farmer: {
          select: {
            id: true,
            name: true,
            phone: true,
            avatarUrl: true,
            trustScore: true,
            isVerifiedBreeder: true,
            paymentQrUrl: true,
            paymentInfo: true,
          },
        },
        holders: {
          include: {
            user: {
              select: { id: true, name: true, avatarUrl: true },
            },
          },
        },
        media: { orderBy: { takenAt: "desc" } },
        transfers: {
          orderBy: { createdAt: "desc" },
          take: 20,
        },
      },
    });

    if (!animal) return errorResponse("Animal not found", 404);

    const soldTokens = animal.holders.reduce((sum, h) => sum + h.tokens, 0);

    return ok({
      ...animal,
      soldTokens,
      availableTokens: animal.totalTokens - soldTokens,
      priceHistory: JSON.parse(animal.priceHistory),
      gainPercent: animal.initialPriceKgs > 0
        ? Math.round(
            ((animal.currentPriceKgs - animal.initialPriceKgs) /
              animal.initialPriceKgs) *
              100
          )
        : 0,
    });
  } catch (error) {
    return handleError(error);
  }
}
