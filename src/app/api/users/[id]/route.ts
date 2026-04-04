import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { ok, errorResponse, handleError } from "@/lib/response";

export async function GET(
  _req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;

    const user = await prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        name: true,
        avatarUrl: true,
        regionId: true,
        village: true,
        bio: true,
        trustScore: true,
        isVerifiedBreeder: true,
        createdAt: true,
        region: { select: { nameKy: true, nameRu: true } },
        _count: {
          select: {
            listings: { where: { status: "ACTIVE" } },
            reviewsReceived: true,
          },
        },
        listings: {
          where: { status: "ACTIVE" },
          orderBy: { createdAt: "desc" },
          take: 10,
          include: {
            media: { orderBy: { sortOrder: "asc" }, take: 1 },
            region: { select: { nameKy: true, nameRu: true } },
          },
        },
        reviewsReceived: {
          orderBy: { createdAt: "desc" },
          take: 10,
          include: {
            reviewer: { select: { name: true, avatarUrl: true } },
          },
        },
      },
    });

    if (!user) return errorResponse("User not found", 404);
    return ok(user);
  } catch (error) {
    return handleError(error);
  }
}
