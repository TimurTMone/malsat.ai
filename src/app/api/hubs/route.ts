import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth, authenticateRequest } from "@/lib/auth";
import { ok, handleError } from "@/lib/response";
import { randomBytes } from "crypto";

// GET — list hubs I'm a member of
export async function GET(req: NextRequest) {
  try {
    const auth = requireAuth(req);

    const memberships = await prisma.hubMember.findMany({
      where: { userId: auth.userId },
      include: {
        hub: {
          include: {
            _count: { select: { members: true, drops: true } },
          },
        },
      },
      orderBy: { joinedAt: "desc" },
    });

    return ok({
      hubs: memberships.map((m) => ({
        ...m.hub,
        myRole: m.role,
        myApartment: m.apartment,
        memberCount: m.hub._count.members,
        dropCount: m.hub._count.drops,
      })),
    });
  } catch (error) {
    return handleError(error);
  }
}

// POST — create a new hub (apartment complex)
export async function POST(req: NextRequest) {
  try {
    const auth = requireAuth(req);
    const body = await req.json();

    // Generate 6-char join code
    const code = "MAL-" + randomBytes(3).toString("hex").toUpperCase().slice(0, 4);

    const hub = await prisma.hub.create({
      data: {
        name: body.name,
        address: body.address,
        lat: body.lat,
        lng: body.lng,
        city: body.city,
        regionId: body.regionId,
        photoUrl: body.photoUrl,
        code,
        createdById: auth.userId,
        members: {
          create: {
            userId: auth.userId,
            role: "ADMIN",
            apartment: body.apartment,
          },
        },
      },
      include: {
        _count: { select: { members: true } },
      },
    });

    return ok(hub, 201);
  } catch (error) {
    return handleError(error);
  }
}
