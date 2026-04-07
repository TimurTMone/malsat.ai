import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth } from "@/lib/auth";
import { ok, errorResponse, handleError } from "@/lib/response";

type Ctx = { params: Promise<{ id: string }> };

export async function GET(req: NextRequest, ctx: Ctx) {
  try {
    const auth = requireAuth(req);
    const { id: dropId } = await ctx.params;

    const drop = await prisma.butcherDrop.findUnique({ where: { id: dropId } });
    if (!drop) return errorResponse("Drop not found", 404);

    const isSeller = drop.sellerId === auth.userId;

    // Seller sees all orders; buyer sees only their own
    const where = isSeller
      ? { dropId }
      : { dropId, buyerId: auth.userId };

    const orders = await prisma.meatOrder.findMany({
      where,
      orderBy: { createdAt: "desc" },
      include: {
        buyer: {
          select: {
            id: true,
            name: true,
            phone: isSeller, // only seller sees phone
            avatarUrl: true,
          },
        },
      },
    });

    return ok({ orders, isSeller });
  } catch (error) {
    return handleError(error);
  }
}
