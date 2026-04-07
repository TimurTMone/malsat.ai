import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth } from "@/lib/auth";
import { ok, handleError } from "@/lib/response";

// GET own profile
export async function GET(req: NextRequest) {
  try {
    const auth = requireAuth(req);

    const user = await prisma.user.findUnique({
      where: { id: auth.userId },
      select: {
        id: true,
        phone: true,
        name: true,
        avatarUrl: true,
        bio: true,
        regionId: true,
        village: true,
        trustScore: true,
        isVerifiedBreeder: true,
        paymentQrUrl: true,
        paymentInfo: true,
        savedAddress: true,
        preferredLang: true,
        createdAt: true,
        region: { select: { nameKy: true, nameRu: true } },
        _count: {
          select: {
            listings: { where: { status: "ACTIVE" } },
            drops: { where: { status: { in: ["OPEN", "UPCOMING"] } } },
            orders: true,
          },
        },
      },
    });

    return ok(user);
  } catch (error) {
    return handleError(error);
  }
}

// PATCH update own profile
export async function PATCH(req: NextRequest) {
  try {
    const auth = requireAuth(req);
    const body = await req.json();

    const updated = await prisma.user.update({
      where: { id: auth.userId },
      data: {
        ...(body.name !== undefined && { name: body.name }),
        ...(body.bio !== undefined && { bio: body.bio }),
        ...(body.village !== undefined && { village: body.village }),
        ...(body.paymentQrUrl !== undefined && {
          paymentQrUrl: body.paymentQrUrl,
        }),
        ...(body.paymentInfo !== undefined && {
          paymentInfo: body.paymentInfo,
        }),
        ...(body.savedAddress !== undefined && {
          savedAddress: body.savedAddress,
        }),
        ...(body.preferredLang !== undefined && {
          preferredLang: body.preferredLang,
        }),
      },
      select: {
        id: true,
        phone: true,
        name: true,
        avatarUrl: true,
        bio: true,
        paymentQrUrl: true,
        paymentInfo: true,
        savedAddress: true,
        preferredLang: true,
      },
    });

    return ok(updated);
  } catch (error) {
    return handleError(error);
  }
}
