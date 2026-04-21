import { NextRequest } from "next/server";
import { verifyToken, signAccessToken } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { ok, errorResponse } from "@/lib/response";

export async function POST(req: NextRequest) {
  const { refreshToken } = await req.json();

  if (!refreshToken) {
    return errorResponse("Refresh token required", 400);
  }

  const payload = verifyToken(refreshToken);
  if (!payload) {
    return errorResponse("Invalid refresh token", 401);
  }

  // Verify the user still exists — after a DB reset, stale refresh tokens
  // must not mint new access tokens, otherwise the client loops on 401.
  const userExists = await prisma.user.findUnique({
    where: { id: payload.userId },
    select: { id: true },
  });
  if (!userExists) {
    return errorResponse("Stale session — re-login required", 401);
  }

  const accessToken = signAccessToken({
    userId: payload.userId,
    phone: payload.phone,
  });

  return ok({ accessToken });
}
