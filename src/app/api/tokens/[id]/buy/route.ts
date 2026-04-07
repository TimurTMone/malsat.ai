import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth } from "@/lib/auth";
import { ok, errorResponse, handleError } from "@/lib/response";

type Ctx = { params: Promise<{ id: string }> };

// POST — buy tokens of an animal
export async function POST(req: NextRequest, ctx: Ctx) {
  try {
    const auth = requireAuth(req);
    const { id: animalId } = await ctx.params;
    const body = await req.json();
    const tokens: number = body.tokens;

    if (!tokens || tokens <= 0)
      return errorResponse("tokens must be positive");

    const animal = await prisma.livestockAnimal.findUnique({
      where: { id: animalId },
      include: { holders: { select: { tokens: true } } },
    });
    if (!animal) return errorResponse("Animal not found", 404);

    if (animal.farmerId === auth.userId)
      return errorResponse("Cannot buy tokens of your own animal");

    if (animal.status === "BUTCHERED" || animal.status === "BUTCHER_SCHEDULED")
      return errorResponse("This animal is no longer available for purchase");

    const soldTokens = animal.holders.reduce((sum, h) => sum + h.tokens, 0);
    const available = animal.totalTokens - soldTokens;

    if (tokens > available)
      return errorResponse(`Only ${available} tokens available`);

    const totalPrice = tokens * animal.currentPriceKgs;

    // Upsert token holder + create transfer record atomically
    await prisma.$transaction([
      prisma.tokenHolder.upsert({
        where: {
          animalId_userId: { animalId, userId: auth.userId },
        },
        create: {
          animalId,
          userId: auth.userId,
          tokens,
        },
        update: {
          tokens: { increment: tokens },
        },
      }),
      prisma.tokenTransfer.create({
        data: {
          animalId,
          toUserId: auth.userId,
          tokens,
          priceKgs: totalPrice,
          type: "BUY",
          receiptUrl: body.receiptUrl,
        },
      }),
      // If all tokens sold, mark as FULLY_OWNED
      ...(soldTokens + tokens >= animal.totalTokens
        ? [
            prisma.livestockAnimal.update({
              where: { id: animalId },
              data: { status: "FULLY_OWNED" },
            }),
          ]
        : []),
    ]);

    return ok({
      tokens,
      totalPrice,
      meatKg: tokens * animal.meatPerTokenKg,
      message: `You now own ${tokens} token(s) of ${animal.name}`,
    }, 201);
  } catch (error) {
    return handleError(error);
  }
}
