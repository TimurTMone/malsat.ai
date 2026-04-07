import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth } from "@/lib/auth";
import { ok, errorResponse, handleError } from "@/lib/response";

// POST — join a hub by code
export async function POST(req: NextRequest) {
  try {
    const auth = requireAuth(req);
    const body = await req.json();
    const code: string = body.code?.toUpperCase().trim();

    if (!code) return errorResponse("Hub code is required");

    const hub = await prisma.hub.findUnique({ where: { code } });
    if (!hub) return errorResponse("Hub not found. Check the code.", 404);

    // Check if already a member
    const existing = await prisma.hubMember.findUnique({
      where: { hubId_userId: { hubId: hub.id, userId: auth.userId } },
    });
    if (existing) return errorResponse("You're already a member of this hub");

    const member = await prisma.hubMember.create({
      data: {
        hubId: hub.id,
        userId: auth.userId,
        apartment: body.apartment,
      },
      include: {
        hub: {
          include: { _count: { select: { members: true } } },
        },
      },
    });

    return ok({
      hub: member.hub,
      apartment: member.apartment,
      role: member.role,
    }, 201);
  } catch (error) {
    return handleError(error);
  }
}
