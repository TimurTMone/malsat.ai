import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth } from "@/lib/auth";
import { ok, errorResponse, handleError } from "@/lib/response";

export async function GET(req: NextRequest) {
  try {
    const auth = requireAuth(req);

    const favorites = await prisma.favorite.findMany({
      where: { userId: auth.userId },
      include: {
        listing: {
          include: {
            media: { orderBy: { sortOrder: "asc" }, take: 1 },
            seller: {
              select: {
                id: true,
                name: true,
                trustScore: true,
                isVerifiedBreeder: true,
              },
            },
            region: { select: { id: true, nameKy: true, nameRu: true } },
          },
        },
      },
      orderBy: { createdAt: "desc" },
    });

    return ok(favorites);
  } catch (error) {
    return handleError(error);
  }
}

export async function POST(req: NextRequest) {
  try {
    const auth = requireAuth(req);
    const { listingId } = await req.json();

    if (!listingId) return errorResponse("listingId required", 400);

    // Toggle: if exists, delete; if not, create
    const existing = await prisma.favorite.findUnique({
      where: { userId_listingId: { userId: auth.userId, listingId } },
    });

    if (existing) {
      await prisma.favorite.delete({ where: { id: existing.id } });
      await prisma.listing.update({
        where: { id: listingId },
        data: { favoritesCount: { decrement: 1 } },
      });
      return ok({ favorited: false });
    }

    await prisma.favorite.create({
      data: { userId: auth.userId, listingId },
    });
    await prisma.listing.update({
      where: { id: listingId },
      data: { favoritesCount: { increment: 1 } },
    });

    return ok({ favorited: true });
  } catch (error) {
    return handleError(error);
  }
}
