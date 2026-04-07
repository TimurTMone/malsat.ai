import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth } from "@/lib/auth";
import { ok, handleError } from "@/lib/response";
import { Prisma } from "@/generated/prisma/client";
import { getDemoDrops } from "@/lib/demo-drops";

export async function GET(req: NextRequest) {
  const url = new URL(req.url);
  const category = url.searchParams.get("category");
  const status = url.searchParams.get("status");
  const regionId = url.searchParams.get("regionId");
  const sort = url.searchParams.get("sort") || "soonest";
  const page = parseInt(url.searchParams.get("page") || "1");
  const limit = Math.min(parseInt(url.searchParams.get("limit") || "20"), 50);
  const skip = (page - 1) * limit;

  const demoFallback = () =>
    ok(getDemoDrops({ category, status, sort, page, limit }));

  try {
    const where: Prisma.ButcherDropWhereInput = {};

    if (category) where.category = category as Prisma.EnumAnimalCategoryFilter;
    if (status) where.status = status as Prisma.EnumDropStatusFilter;
    if (regionId) where.regionId = regionId;

    // By default only show OPEN + UPCOMING drops
    if (!status) {
      where.status = { in: ["OPEN", "UPCOMING"] };
    }

    const orderBy: Prisma.ButcherDropOrderByWithRelationInput =
      sort === "price_asc"
        ? { pricePerKg: "asc" }
        : sort === "price_desc"
        ? { pricePerKg: "desc" }
        : sort === "newest"
        ? { createdAt: "desc" }
        : { butcherDate: "asc" }; // soonest

    const [drops, total] = await Promise.all([
      prisma.butcherDrop.findMany({
        where,
        orderBy,
        skip,
        take: limit,
        include: {
          media: { orderBy: { sortOrder: "asc" }, take: 1 },
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
      }),
      prisma.butcherDrop.count({ where }),
    ]);

    if (total === 0) return demoFallback();

    const formatted = drops.map((d) => ({
      ...d,
      portionPresets: JSON.parse(d.portionPresets),
      claimedWeightKg: d.totalWeightKg - d.remainingWeightKg,
      progressPercent: Math.round(
        ((d.totalWeightKg - d.remainingWeightKg) / d.totalWeightKg) * 100
      ),
      orderCount: d._count.orders,
      _count: undefined,
    }));

    return ok({
      drops: formatted,
      pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
    });
  } catch (error) {
    console.warn("[drops] demo fallback:", error);
    return demoFallback();
  }
}

export async function POST(req: NextRequest) {
  try {
    const auth = requireAuth(req);
    const body = await req.json();

    const drop = await prisma.butcherDrop.create({
      data: {
        sellerId: auth.userId,
        title: body.title,
        description: body.description,
        category: body.category,
        breed: body.breed,
        totalWeightKg: body.totalWeightKg,
        remainingWeightKg: body.totalWeightKg, // starts full
        pricePerKg: body.pricePerKg,
        minOrderKg: body.minOrderKg || 3,
        maxOrderKg: body.maxOrderKg,
        portionPresets: JSON.stringify(body.portionPresets || [5, 10, 15]),
        butcherDate: new Date(body.butcherDate),
        pickupAddress: body.pickupAddress,
        pickupLat: body.pickupLat,
        pickupLng: body.pickupLng,
        regionId: body.regionId,
        village: body.village,
        status: body.status || "OPEN",
        expiresAt: body.expiresAt
          ? new Date(body.expiresAt)
          : new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
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

    return ok(
      { ...drop, portionPresets: JSON.parse(drop.portionPresets) },
      201
    );
  } catch (error) {
    return handleError(error);
  }
}
