import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth } from "@/lib/auth";
import { ok, handleError } from "@/lib/response";
import { Prisma } from "@/generated/prisma/client";

export async function GET(req: NextRequest) {
  const url = new URL(req.url);
  const category = url.searchParams.get("category");
  const minPrice = url.searchParams.get("minPrice");
  const maxPrice = url.searchParams.get("maxPrice");
  const regionId = url.searchParams.get("regionId");
  const breed = url.searchParams.get("breed");
  const gender = url.searchParams.get("gender");
  const sort = url.searchParams.get("sort") || "newest";
  const page = parseInt(url.searchParams.get("page") || "1");
  const limit = Math.min(parseInt(url.searchParams.get("limit") || "20"), 50);
  const skip = (page - 1) * limit;

  try {
    const where: Prisma.ListingWhereInput = {
      status: "ACTIVE",
    };

    if (category) where.category = category as Prisma.EnumAnimalCategoryFilter;
    if (regionId) where.regionId = regionId;
    if (breed) where.breed = { contains: breed, mode: "insensitive" };
    if (gender) where.gender = gender as Prisma.EnumAnimalGenderNullableFilter;
    if (minPrice || maxPrice) {
      where.priceKgs = {};
      if (minPrice) where.priceKgs.gte = parseInt(minPrice);
      if (maxPrice) where.priceKgs.lte = parseInt(maxPrice);
    }

    const orderBy: Prisma.ListingOrderByWithRelationInput =
      sort === "price_asc"
        ? { priceKgs: "asc" }
        : sort === "price_desc"
        ? { priceKgs: "desc" }
        : { createdAt: "desc" };

    const [listings, total] = await Promise.all([
      prisma.listing.findMany({
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
        },
      }),
      prisma.listing.count({ where }),
    ]);

    return ok({
      listings,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    return handleError(error);
  }
}

export async function POST(req: NextRequest) {
  try {
    const auth = requireAuth(req);
    const body = await req.json();

    const listing = await prisma.listing.create({
      data: {
        sellerId: auth.userId,
        category: body.category,
        subcategory: body.subcategory,
        breed: body.breed,
        title: body.title,
        description: body.description,
        priceKgs: body.priceKgs,
        ageMonths: body.ageMonths,
        weightKg: body.weightKg,
        gender: body.gender,
        healthStatus: body.healthStatus,
        hasVetCert: body.hasVetCert || false,
        locationLat: body.locationLat,
        locationLng: body.locationLng,
        regionId: body.regionId,
        village: body.village,
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
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

    return ok(listing, 201);
  } catch (error) {
    return handleError(error);
  }
}
