import { NextRequest } from "next/server";
import { verifyToken, signAccessToken } from "@/lib/auth";
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

  const accessToken = signAccessToken({
    userId: payload.userId,
    phone: payload.phone,
  });

  return ok({ accessToken });
}
