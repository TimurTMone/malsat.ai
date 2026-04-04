import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth, authenticateRequest } from "@/lib/auth";
import { ok, errorResponse, handleError } from "@/lib/response";

export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;

    const listing = await prisma.listing.findUnique({
      where: { id },
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
            createdAt: true,
            _count: { select: { listings: true, reviewsReceived: true } },
          },
        },
        region: true,
      },
    });

    if (!listing) {
      return errorResponse("Listing not found", 404);
    }

    // Increment views
    await prisma.listing.update({
      where: { id },
      data: { viewsCount: { increment: 1 } },
    });

    // Check if current user favorited this
    let isFavorited = false;
    const auth = authenticateRequest(req);
    if (auth) {
      const fav = await prisma.favorite.findUnique({
        where: { userId_listingId: { userId: auth.userId, listingId: id } },
      });
      isFavorited = !!fav;
    }

    return ok({ ...listing, isFavorited });
  } catch (error) {
    return handleError(error);
  }
}

export async function PATCH(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const auth = requireAuth(req);
    const { id } = await params;
    const body = await req.json();

    const listing = await prisma.listing.findUnique({ where: { id } });
    if (!listing) return errorResponse("Listing not found", 404);
    if (listing.sellerId !== auth.userId) return errorResponse("Forbidden", 403);

    const updated = await prisma.listing.update({
      where: { id },
      data: body,
    });

    return ok(updated);
  } catch (error) {
    return handleError(error);
  }
}

export async function DELETE(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const auth = requireAuth(req);
    const { id } = await params;

    const listing = await prisma.listing.findUnique({ where: { id } });
    if (!listing) return errorResponse("Listing not found", 404);
    if (listing.sellerId !== auth.userId) return errorResponse("Forbidden", 403);

    await prisma.listing.delete({ where: { id } });
    return ok({ success: true });
  } catch (error) {
    return handleError(error);
  }
}
