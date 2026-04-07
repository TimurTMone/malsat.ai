import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth } from "@/lib/auth";
import { ok, errorResponse, handleError } from "@/lib/response";
import { getDemoDropById } from "@/lib/demo-drops";

type Ctx = { params: Promise<{ id: string }> };

export async function GET(req: NextRequest, ctx: Ctx) {
  const { id } = await ctx.params;

  // Demo fallback
  if (id.startsWith("demo-")) {
    const demo = getDemoDropById(id);
    if (!demo) return errorResponse("Drop not found", 404);
    return ok(demo);
  }

  try {
    const drop = await prisma.butcherDrop.update({
      where: { id },
      data: { viewsCount: { increment: 1 } },
      include: {
        media: { orderBy: { sortOrder: "asc" } },
        seller: {
          select: {
            id: true,
            name: true,
            avatarUrl: true,
            phone: true,
            trustScore: true,
            isVerifiedBreeder: true,
          },
        },
        region: { select: { id: true, nameKy: true, nameRu: true } },
        _count: { select: { orders: true } },
      },
    });

    if (!drop) return errorResponse("Drop not found", 404);

    return ok({
      ...drop,
      portionPresets: JSON.parse(drop.portionPresets),
      claimedWeightKg: drop.totalWeightKg - drop.remainingWeightKg,
      progressPercent: Math.round(
        ((drop.totalWeightKg - drop.remainingWeightKg) / drop.totalWeightKg) *
          100
      ),
      orderCount: drop._count.orders,
      _count: undefined,
    });
  } catch (error) {
    return handleError(error);
  }
}

export async function PATCH(req: NextRequest, ctx: Ctx) {
  try {
    const auth = requireAuth(req);
    const { id } = await ctx.params;

    const drop = await prisma.butcherDrop.findUnique({ where: { id } });
    if (!drop) return errorResponse("Drop not found", 404);
    if (drop.sellerId !== auth.userId)
      return errorResponse("Not your drop", 403);

    const body = await req.json();

    const updated = await prisma.butcherDrop.update({
      where: { id },
      data: {
        ...(body.title !== undefined && { title: body.title }),
        ...(body.description !== undefined && { description: body.description }),
        ...(body.pricePerKg !== undefined && { pricePerKg: body.pricePerKg }),
        ...(body.minOrderKg !== undefined && { minOrderKg: body.minOrderKg }),
        ...(body.maxOrderKg !== undefined && { maxOrderKg: body.maxOrderKg }),
        ...(body.portionPresets !== undefined && {
          portionPresets: JSON.stringify(body.portionPresets),
        }),
        ...(body.butcherDate !== undefined && {
          butcherDate: new Date(body.butcherDate),
        }),
        ...(body.pickupAddress !== undefined && {
          pickupAddress: body.pickupAddress,
        }),
        ...(body.status !== undefined && { status: body.status }),
      },
      include: {
        media: true,
        seller: {
          select: {
            id: true,
            name: true,
            phone: true,
            trustScore: true,
            isVerifiedBreeder: true,
          },
        },
      },
    });

    return ok({
      ...updated,
      portionPresets: JSON.parse(updated.portionPresets),
    });
  } catch (error) {
    return handleError(error);
  }
}

export async function DELETE(req: NextRequest, ctx: Ctx) {
  try {
    const auth = requireAuth(req);
    const { id } = await ctx.params;

    const drop = await prisma.butcherDrop.findUnique({ where: { id } });
    if (!drop) return errorResponse("Drop not found", 404);
    if (drop.sellerId !== auth.userId)
      return errorResponse("Not your drop", 403);

    await prisma.butcherDrop.update({
      where: { id },
      data: { status: "CANCELLED" },
    });

    return ok({ deleted: true });
  } catch (error) {
    return handleError(error);
  }
}
