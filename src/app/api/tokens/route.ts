import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth } from "@/lib/auth";
import { ok, handleError } from "@/lib/response";
import { Prisma } from "@/generated/prisma/client";

// GET — list animals available for token purchase
export async function GET(req: NextRequest) {
  const url = new URL(req.url);
  const category = url.searchParams.get("category");
  const page = parseInt(url.searchParams.get("page") || "1");
  const limit = Math.min(parseInt(url.searchParams.get("limit") || "20"), 50);
  const skip = (page - 1) * limit;

  try {
    const where: Prisma.LivestockAnimalWhereInput = {
      status: { in: ["LISTED", "FULLY_OWNED", "GRAZING"] },
    };
    if (category) where.category = category as any;

    const [animals, total] = await Promise.all([
      prisma.livestockAnimal.findMany({
        where,
        orderBy: { createdAt: "desc" },
        skip,
        take: limit,
        include: {
          farmer: {
            select: {
              id: true,
              name: true,
              avatarUrl: true,
              trustScore: true,
              isVerifiedBreeder: true,
            },
          },
          media: { take: 1, orderBy: { takenAt: "desc" } },
          _count: { select: { holders: true } },
          holders: {
            select: { tokens: true },
          },
        },
      }),
      prisma.livestockAnimal.count({ where }),
    ]);

    const formatted = animals.map((a) => {
      const soldTokens = a.holders.reduce((sum, h) => sum + h.tokens, 0);
      return {
        ...a,
        soldTokens,
        availableTokens: a.totalTokens - soldTokens,
        holdersCount: a._count.holders,
        priceHistory: JSON.parse(a.priceHistory),
        holders: undefined,
        _count: undefined,
      };
    });

    return ok({
      animals: formatted,
      pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
    });
  } catch (error) {
    return handleError(error);
  }
}

// POST — farmer lists a new animal for tokenized sale
export async function POST(req: NextRequest) {
  try {
    const auth = requireAuth(req);
    const body = await req.json();

    const animal = await prisma.livestockAnimal.create({
      data: {
        farmerId: auth.userId,
        name: body.name,
        category: body.category,
        breed: body.breed,
        gender: body.gender,
        birthDate: body.birthDate ? new Date(body.birthDate) : null,
        photoUrl: body.photoUrl,
        currentWeightKg: body.currentWeightKg,
        healthStatus: body.healthStatus,
        hasVetCert: body.hasVetCert || false,
        locationVillage: body.locationVillage,
        locationRegion: body.locationRegion,
        totalTokens: body.totalTokens || 10,
        tokenPriceKgs: body.tokenPriceKgs,
        meatPerTokenKg: body.meatPerTokenKg,
        initialPriceKgs: body.tokenPriceKgs,
        currentPriceKgs: body.tokenPriceKgs,
        butcherDate: body.butcherDate ? new Date(body.butcherDate) : null,
      },
      include: {
        farmer: {
          select: {
            id: true,
            name: true,
            trustScore: true,
            isVerifiedBreeder: true,
          },
        },
      },
    });

    return ok(animal, 201);
  } catch (error) {
    return handleError(error);
  }
}
