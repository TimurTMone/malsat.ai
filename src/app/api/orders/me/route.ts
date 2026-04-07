import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth } from "@/lib/auth";
import { ok, handleError } from "@/lib/response";

export async function GET(req: NextRequest) {
  try {
    const auth = requireAuth(req);
    const url = new URL(req.url);
    const status = url.searchParams.get("status");
    const page = parseInt(url.searchParams.get("page") || "1");
    const limit = Math.min(parseInt(url.searchParams.get("limit") || "20"), 50);
    const skip = (page - 1) * limit;

    const where: any = { buyerId: auth.userId };
    if (status) where.status = status;

    const [orders, total] = await Promise.all([
      prisma.meatOrder.findMany({
        where,
        orderBy: { createdAt: "desc" },
        skip,
        take: limit,
        include: {
          drop: {
            select: {
              id: true,
              title: true,
              category: true,
              breed: true,
              pricePerKg: true,
              butcherDate: true,
              pickupAddress: true,
              village: true,
              status: true,
              seller: {
                select: {
                  id: true,
                  name: true,
                  phone: true,
                  avatarUrl: true,
                  trustScore: true,
                },
              },
              media: { orderBy: { sortOrder: "asc" }, take: 1 },
            },
          },
        },
      }),
      prisma.meatOrder.count({ where }),
    ]);

    return ok({
      orders,
      pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
    });
  } catch (error) {
    return handleError(error);
  }
}
