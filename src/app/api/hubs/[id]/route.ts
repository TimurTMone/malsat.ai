import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { authenticateRequest } from "@/lib/auth";
import { ok, errorResponse, handleError } from "@/lib/response";

type Ctx = { params: Promise<{ id: string }> };

// GET — hub detail with members and recent drops
export async function GET(req: NextRequest, ctx: Ctx) {
  try {
    const { id } = await ctx.params;

    const hub = await prisma.hub.findUnique({
      where: { id },
      include: {
        members: {
          include: {
            user: {
              select: { id: true, name: true, avatarUrl: true, phone: true },
            },
          },
          orderBy: { joinedAt: "asc" },
        },
        drops: {
          include: {
            drop: {
              include: {
                media: { take: 1 },
                seller: {
                  select: {
                    id: true,
                    name: true,
                    trustScore: true,
                    isVerifiedBreeder: true,
                  },
                },
                _count: { select: { orders: true } },
              },
            },
          },
          orderBy: { drop: { butcherDate: "asc" } },
        },
        _count: { select: { members: true } },
      },
    });

    if (!hub) return errorResponse("Hub not found", 404);

    // Format drops
    const drops = hub.drops.map((hd) => ({
      ...hd.drop,
      portionPresets: JSON.parse(hd.drop.portionPresets),
      claimedWeightKg: hd.drop.totalWeightKg - hd.drop.remainingWeightKg,
      progressPercent: Math.round(
        ((hd.drop.totalWeightKg - hd.drop.remainingWeightKg) /
          hd.drop.totalWeightKg) *
          100
      ),
      orderCount: hd.drop._count.orders,
    }));

    return ok({
      ...hub,
      drops,
      memberCount: hub._count.members,
    });
  } catch (error) {
    return handleError(error);
  }
}
