import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth } from "@/lib/auth";
import { ok, handleError } from "@/lib/response";

// GET /api/butcher-partners?regionId=...
// Returns active butcher partners, optionally filtered by region.
// P0 ships with one Bishkek partner.
export async function GET(req: NextRequest) {
  try {
    requireAuth(req);
    const regionId = req.nextUrl.searchParams.get("regionId");

    const partners = await prisma.butcherPartner.findMany({
      where: {
        isActive: true,
        ...(regionId && { regionId }),
      },
      select: {
        id: true,
        name: true,
        description: true,
        phone: true,
        regionId: true,
        halalCertUrl: true,
        pricePerKgByCategory: true,
        imamFeeKgs: true,
        deliveryFeeKgs: true,
        region: { select: { id: true, nameKy: true, nameRu: true } },
        user: {
          select: {
            id: true,
            name: true,
            avatarUrl: true,
            trustScore: true,
            isVerifiedBreeder: true,
          },
        },
      },
      orderBy: { createdAt: "asc" },
    });

    return ok({ partners });
  } catch (error) {
    return handleError(error);
  }
}
